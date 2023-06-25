//
//  InputUserInfoViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/11.
//

import UIKit
import Firebase
import PKHUD
import SCLAlertView_Objective_C

class InputUserInfoViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var whetherSetImage = false
    var email:String!
    var password:String!
    let areas:[String] = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県","海外"]
    let numbers: [Int] = Array(0...99)
    var agePikcerView = UIPickerView()
    var areaPikcerView = UIPickerView()
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var agedTextField:NoEditTextField!
    @IBOutlet weak var areaTextField:NoEditTextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ユーザー情報登録"
        agedTextField.delegate = self
        areaTextField.delegate = self
        nameTextField.delegate = self
        createPickerView()
        nextButton.layer.cornerRadius = 10
        userImageView.layer.cornerRadius = 10
        userImageView.isUserInteractionEnabled = true
        let tapNarrowGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setUserImage))
        userImageView.addGestureRecognizer(tapNarrowGestureRecognizer)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        if whetherSetImage == false{
            let alert = UIAlertController(title: "まだプロフィール画像が設定されていません。", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        createUser()
    }
    
    func createPickerView() {
        agePikcerView.delegate = self
        agePikcerView.dataSource = self
        agedTextField.inputView = agePikcerView
        areaPikcerView.delegate = self
        areaPikcerView.dataSource = self
        areaTextField.inputView = areaPikcerView
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        agedTextField.inputAccessoryView = toolbar
        areaTextField.inputAccessoryView = toolbar
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func setUserImage(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        let alert = SCLAlertView()
        alert.addButton("アルバムを開く", actionBlock: {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alert.addButton("カメラを開く", actionBlock: {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alert.showSuccess(self, title: "プロフィール画像を設定", subTitle: nil, closeButtonTitle: "キャンセル", duration: 0)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            userImageView.image = editImage
        }else if let originalImage = info[.originalImage] as? UIImage{
            userImageView.image = originalImage
        }
        dismiss(animated:true, completion: nil)
        whetherSetImage = true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let ageIsEmpty = agedTextField.text?.isEmpty ?? false
        let areaIsEmpty = areaTextField.text?.isEmpty ?? false
        let nameIsEmpty = nameTextField.text?.isEmpty ?? false
        
        if ageIsEmpty == true || nameIsEmpty == true || areaIsEmpty == true{
            nextButton.isEnabled = false
        }else {
            nextButton.isEnabled = true
        }
    }
    
    private func createUser(){
        //①画像をURLに変換してFirebaseに保存
        HUD.show(.progress)
        let profileImage = userImageView.image ?? UIImage(named: "noImage")
        guard let uploadProfileImage = profileImage?.jpegData(compressionQuality: 0.5) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profie_image").child(fileName)
        
        storageRef.putData(uploadProfileImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                guard let userImageUrl = url?.absoluteString else {return}
                
                //②FirebaseAuthでユーザーを作成
                guard self.email != "" else {return}
                guard self.password != "" else {return}
                Auth.auth().createUser(withEmail: self.email, password: self.password) { (res, err) in
                    if let err = err{
                        print("認証情報の保存に失敗しました。\(err)")
                        HUD.hide()
                        let alert = UIAlertController(title: "登録失敗", message: "恐れ入りますが、最初からやり直してください。入力されたメールアドレスを既に使用されている場合はまずアカウントを削除してください。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    //③FireStoreに細かなユーザーを保存
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    let docData = [
                        "uid": uid,
                        "userId": self.email!,
                        "name": self.nameTextField.text!,
                        "createdAt": Timestamp(),
                        "area": self.areaTextField.text!,
                        "userImageUrl": userImageUrl,
                        "age": self.agedTextField.text!,
                        "lastLogin":Timestamp(),
                        "fcmToken":"",
                        "messageNotification":true,
                        "latitude":Double(),
                        "longitude":Double(),
                        
                    ] as [String : Any]
                    
                    Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                        if let err = err {
                            print("Firestoreへの保存に失敗しました。\(err)")
                            HUD.hide()
                            let alert = UIAlertController(title: "登録失敗", message: "恐れ入りますが、入力した内容をご確認ください。", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        HUD.hide()
                        let alert = SCLAlertView()
                        alert.addButton("進む", actionBlock: {
                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        alert.showSuccess(self, title: "アカウント作成に成功しました！", subTitle: "ご登録いただき誠にありがとうございます。「進む」をタップしてコンテンツ画面へお進みください。", closeButtonTitle: nil, duration: 0)
                        
                    }
                }
            }
        }
    }
    
}

extension InputUserInfoViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case agePikcerView:
            if agedTextField.text == ""{
                agedTextField.text = String(numbers[0]) + "歳"
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
            agedTextField.text = String(numbers[row]) + "歳"
        case areaPikcerView:
            areaTextField.text = areas[row]
        default: break
        }
    }
}
