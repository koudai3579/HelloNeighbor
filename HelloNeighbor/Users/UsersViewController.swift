//
//  UsersViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/05/31.
//

import UIKit
import Firebase
import Nuke
import CoreLocation

private let cellId = "cellId"

class UsersViewController: UIViewController{
    
    var executionNarrowUser = false
    var locationManager : CLLocationManager?
    var users = [User]()
    var myLocation = [Double]()
    var areas = [String]()
    var ages = [String]()
    var logins = [String]()
    var Within1WeekRegistration = false
    var exsistProfieText = false
    var sortOrder = "デフォルト"
    @IBOutlet weak var usersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        getLocation()
        fetchUsers()
        setRearrangeButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if executionNarrowUser == true{
            executionNarrowUser = false
            fetchUsers()
        }
    }
    
    func setRearrangeButton(){
        let actions = [
            UIAction(title: "デフォルト", identifier: UIAction.Identifier("デフォルト"), handler: {_ in }),
            UIAction(title: "距離が近い順", identifier: UIAction.Identifier("距離が近い順"), handler: {_ in }),
            UIAction(title: "登録が新しい順", identifier: UIAction.Identifier("登録が新しい順"), handler: {_ in }),
        ]
        let menu = UIMenu(title: "並び替え",  children: actions)
        let rightBarButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward"), menu: menu)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    @IBAction func NarrowUserBarButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NarrowUserViewController") as! NarrowUserViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchUsers(){
        
        self.users.removeAll()
        self.users = [User]()
        ages = UserDefaults.standard.stringArray(forKey: {"ages"}()) ?? [String]()
        areas = UserDefaults.standard.stringArray(forKey: {"areas"}()) ?? [String]()
        logins = UserDefaults.standard.stringArray(forKey: {"logins"}()) ?? [String]()
        Within1WeekRegistration = UserDefaults.standard.bool(forKey: {"Within1WeekRegistration"}())
        exsistProfieText = UserDefaults.standard.bool(forKey: {"exsistProfieText"}())
        sortOrder = UserDefaults.standard.string(forKey: {"sortOrder"}()) ?? ""
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                self.usersTableView.reloadData()
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
                //検索フィルター
                if user.uid == uid {
                    return
                }
                
                if self.ages != []{
                    if self.ages.contains(user.age) == false{
                        return
                    }
                }
                
                if self.areas != []{
                    if self.areas.contains(user.area) == false{
                        return
                    }
                }
                
                if self.logins != []{
                    let lastLoginScope = self.converLastLoginScope(date: user.lastLogin.dateValue())
                    if self.logins.contains(lastLoginScope) == false{
                        return
                    }
                }
                
                if self.Within1WeekRegistration == true{
                    if self.whetherOneWeekAgo(date: user.createdAt.dateValue()) == false{
                        return
                    }
                }
                
                if self.exsistProfieText == true{
                    if user.profileText == ""{
                        return
                    }
                }
                
                self.users.append(user)
                
                if self.sortOrder == "ログインが新しい順"{
                    self.users.sort { (m1, m2) -> Bool in
                        let m1Date = m1.lastLogin.dateValue()
                        let m2Date = m2.lastLogin.dateValue()
                        return m1Date > m2Date
                    }
                }else if self.sortOrder == "登録が新しい順"{
                    self.users.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                }
                
                self.usersTableView.reloadData()
            })
        }
    }
    
    //2つの位置情報から距離
    func calculateDistanceBetweenLocations(location1: CLLocation, location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
    
    // メートルをキロメートル（整数）に変換
    func metersToKilometers(meters: Double) -> Int {
        let kilometers = meters / 1000
        return Int(kilometers)
    }
    
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager!.startUpdatingLocation()
            locationManager!.requestLocation()
        }else{
            print("位置情報取得が許可されていません。")
        }
    }
    
    private func converLastLoginScope(date: Date) -> String {
        let now = Date()
        
        let oneHourAgo = Date(timeInterval: -60*60, since: now)
        if oneHourAgo < date{
            return "1時間以内"
        }
        
        let twelvefourHourAgo = Date(timeInterval: -60*60*12, since: now)
        if twelvefourHourAgo < date{
            return "12時間以内"
        }
        
        let twentyfourHourAgo = Date(timeInterval: -60*60*24, since: now)
        if twentyfourHourAgo < date{
            return "24時間以内"
        }
        
        let  treeDaysAgo = Date(timeInterval: -60*60*24*3, since: now)
        if treeDaysAgo < date{
            return "3日前以内"
        }
        
        let oneWeekAgo = Date(timeInterval: -60*60*24*7, since: now)
        if oneWeekAgo < date{
            return "1週間以内"
        }
        return "1週間以上前"
    }
    
    private func whetherOneWeekAgo(date: Date) -> Bool {
        let now = Date()
        let oneWeekAgo = Date(timeInterval: -60*60*24*7, since: now)
        if oneWeekAgo < date{
            return true
        }
        return false
    }
    
}

extension UsersViewController: CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate{
    
    //新しいロケーションデータが取得された時に実行
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
            
            if let error = error {
                print("reverseGeocodeLocation Failed: \(error.localizedDescription)")
                return
            }
            
            if (placemarks?[0]) != nil {
                //位置情報をFirebaseに保存する
                self.myLocation = [loc.coordinate.latitude,loc.coordinate.longitude]
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Firestore.firestore().collection("users").document(uid).updateData([
                    "longitude":loc.coordinate.longitude,
                    "latitude":loc.coordinate.latitude,
                ]) { err in
                    if let err = err {
                        print("情報を更新できませんでした。: \(err)")
                        return
                    }
                }
            }
        })
    }
    //ロケーションデータが取得できなかった時に実行
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let userImage = cell.contentView.viewWithTag(1) as! UIImageView
        userImage.backgroundColor = UIColor.blue
        userImage.layer.cornerRadius = 30
        if let url = URL(string: self.users[indexPath.row].userImageUrl){
            Nuke.loadImage(with: url, into: userImage)
        }
        
        if users[indexPath.row].latitude == 0 || self.myLocation[0] == 0{
            let userLabel = cell.contentView.viewWithTag(2) as! UILabel
            userLabel.text = users[indexPath.row].name
            
        }else{
            print("マイロケーション：",self.myLocation[0],self.myLocation[1])
            print("パートーナーロケーション：",users[indexPath.row].latitude,users[indexPath.row].longitude)
            let myLocation = CLLocation(latitude: self.myLocation[0], longitude: self.myLocation[1])
            let partnerLocation = CLLocation(latitude: users[indexPath.row].latitude, longitude: users[indexPath.row].longitude)
            let distance = calculateDistanceBetweenLocations(location1: myLocation, location2: partnerLocation)
            let kilometers = metersToKilometers(meters: distance)
            
            let userLabel = cell.contentView.viewWithTag(2) as! UILabel
            userLabel.text = "\(users[indexPath.row].name)(\(kilometers)km)"
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = users[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
