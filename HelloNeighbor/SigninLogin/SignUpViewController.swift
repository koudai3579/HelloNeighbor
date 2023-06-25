//
//  SignUpViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/11.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nextButton.layer.cornerRadius = 10
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InputUserInfoViewController") as! InputUserInfoViewController
        vc.email = self.emailTextField.text!
        vc.password = self.passwordTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let EmailIsEmpty = emailTextField.text?.isEmpty ?? false
        let PasswordIsEmpty = passwordTextField.text?.isEmpty ?? false
        if EmailIsEmpty == true || PasswordIsEmpty == true {
            nextButton.isEnabled = false
        }else{
            nextButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
