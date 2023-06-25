//
//  ResetPasswordViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/18.
//

import UIKit
import Firebase
import PKHUD

class ResetPasswordViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        sendButton.layer.cornerRadius = 10
        emailTextField.delegate = self

    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if emailTextField.text?.isEmpty == true{
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        HUD.show(.progress)
        self.emailTextField.resignFirstResponder()
        guard let email = emailTextField.text else {return}
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                HUD.hide()
                let alert = UIAlertController(title: "メール送信完了", message: "パスワード再設定用のURLを送りました。タップして、新しいパスワードを設定してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel) { action in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true, completion: nil)
                
            }else{
                HUD.hide()
                print("エラー：\(error?.localizedDescription as Any)")
                HUD.flash(.labeledError(title: "予期せぬエラー", subtitle: "再度お試しください。"), delay: 2)
            }
        }
    }
    
   
}
