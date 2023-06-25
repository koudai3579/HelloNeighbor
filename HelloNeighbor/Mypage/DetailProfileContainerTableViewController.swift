//
//  DetailProfileContainerTableViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/15.
//

import UIKit
import Firebase
import PKHUD
import SCLAlertView_Objective_C
import MessageUI

class DetailProfileContainerTableViewController: UITableViewController, UITextFieldDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profileTextView: PlaceTextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var areaTextField: NoEditTextField!
    @IBOutlet weak var ageTextField: NoEditTextField!
    var user:User!
    var agePikcerView = UIPickerView()
    var areaPikcerView = UIPickerView()
    let areas:[String] = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県","海外"]
    let numbers: [Int] = Array(0...99)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        areaTextField.delegate = self
        ageTextField.delegate = self
        createPickerView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateArea(area:String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).updateData([
            "area": area,
        ]) { err in
            if let err = err {
                print("情報を更新できませんでした。: \(err)")
                return
            }
        }
    }
    
    func updateAge(age:String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).updateData([
            "age": age,
        ]) { err in
            if let err = err {
                print("情報を更新できませんでした。: \(err)")
                return
            }
        }
    }
    
    func createPickerView() {
        agePikcerView.delegate = self
        agePikcerView.dataSource = self
        ageTextField.inputView = agePikcerView
        areaPikcerView.delegate = self
        areaPikcerView.dataSource = self
        areaTextField.inputView = areaPikcerView
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        ageTextField.inputAccessoryView = toolbar
        areaTextField.inputAccessoryView = toolbar
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func fetchMyInfo(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            self.user = User.init(dic: dic!)
            self.ageTextField.text = self.user.age
            self.areaTextField.text  = self.user.area
            self.nameTextField.text = self.user.name
            self.profileTextView.text = self.user.profileText
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //プロフィール文章変更
        if indexPath.section == 1 && indexPath.row == 0{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UpdateProfileTextViewController") as! UpdateProfileTextViewController
            vc.profileText = self.user.profileText
            self.navigationController?.pushViewController(vc, animated: true)
            
            //お問い合わせ
        }else if indexPath.section == 2 && indexPath.row == 0{
            if MFMailComposeViewController.canSendMail()==false {
                let alert = UIAlertController(title: "お問い合わせ失敗", message: "メールを開くことができません。", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                return
            }
            
            let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject("お問い合わせ")
            mailViewController.setToRecipients( ["mail@gmail.com"])
            mailViewController.setMessageBody("お問い合わせ内容", isHTML: false)
            self.present(mailViewController, animated: true, completion: nil)
            
            //ログアウト
        }else if indexPath.section == 2 && indexPath.row == 1{
            let alert = UIAlertController(title: "ログアウトしますか？", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "はい", style: .default) { (action) in
                do {
                    try Auth.auth().signOut()
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        exit(0)
                    }
                }
                catch let error as NSError {
                    print(error)
                }
            }
            let no = UIAlertAction(title: "いいえ", style: .default) { (action) in }
            alert.addAction(ok)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
            
            //アカウント削除
        }else if indexPath.section == 2 && indexPath.row == 2{
            let alert = UIAlertController(title: "アカウントを削除しますか？", message: "※一度削除すると元に戻せません。", preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "削除する", style: .default) { (action) in
                
            }
            let no = UIAlertAction(title: "やめる", style: .default) { (action) in }
            alert.addAction(ok)
            alert.addAction(no)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func deleteAccount(){
        guard let user = Auth.auth().currentUser else {return}
        HUD.show(.progress)
        user.delete() { error in
            if let error = error {
                print("ユーザー削除に失敗しました。\(error)")
                HUD.hide()
                HUD.flash(.labeledError(title: "失敗しました。", subtitle: "時間をおいて再度お試し下さい。"), delay: 2)
                return
            }
            HUD.hide()
            let alert = SCLAlertView()
            alert.addButton("アプリを閉じる", actionBlock: {
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                    exit(0)
                }})
            alert.showSuccess(self, title: "アカウントを削除しました", subTitle: "ご利用いただきありがとうございました。またのご利用をお待ちしております。", closeButtonTitle: nil, duration: 0)
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == nameTextField{
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).updateData([
                "name": nameTextField.text ?? "名前なし",
            ]) { err in
                if let err = err {
                    print("情報を更新できませんでした。: \(err)")
                    return
                }
            }
        }
    }
    
}


extension DetailProfileContainerTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 {
            //セクション1のセルタップを無効に
            return nil
        }
        return indexPath
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case agePikcerView:
            if ageTextField.text == ""{
                ageTextField.text = String(numbers[0]) + "歳"
            }
            return numbers.count
        case areaPikcerView:
            if areaTextField.text == ""{
                areaTextField.text = areas[0]
            }
            return areas.count
        default: break
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case agePikcerView:
            return String(numbers[row]) + "歳"
        case areaPikcerView:
            return areas[row]
        default: break
        }
        return "エラー"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView {
        case agePikcerView:
            ageTextField.text = String(numbers[row]) + "歳"
            updateAge(age: String(numbers[row]) + "歳")
        case areaPikcerView:
            areaTextField.text = areas[row]
            updateArea(area: areas[row])
        default: break
        }
    }
}
