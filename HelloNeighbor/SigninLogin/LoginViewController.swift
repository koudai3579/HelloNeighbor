//
//  LoginViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/11.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 10
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    

    @IBAction func nextButton(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        HUD.show(.progress)
    
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                let alert = UIAlertController(title: "ログイン失敗", message: "Emailとパスワードをご確認ください。\nまた、違反行為を数回行ったユーザーは運営が利用を停止する場合があります。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                HUD.hide()
                self.present(alert, animated: true, completion: nil)
                return
            }
            //ユーザーデータがなければアラートを出して処理停止(二重にチェック)
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument {(snapshot, err ) in
                if let err = err{
                    print("ログインユーザーの取得に失敗しました。\(err)")
                    let alert = UIAlertController(title: "ログイン失敗", message: "Emailとパスワードをご確認ください。\nまた、違反行為を数回行ったユーザーは運営が利用を停止する場合があります。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    HUD.hide()
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let dic = snapshot?.data()
                let user = User.init(dic: dic!)
                if user.uid == ""{
                    HUD.flash(.labeledError(title: "ユーザーが存在しません。", subtitle: "新規登録を行ってください。"), delay: 2)
                    return
                }
                HUD.hide()
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let EmailIsEmpty = emailTextField.text?.isEmpty ?? false
        let PsswordIsEmpty = passwordTextField.text?.isEmpty ?? false
        if EmailIsEmpty || PsswordIsEmpty {
            nextButton.isEnabled = false
        }else{
            nextButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
