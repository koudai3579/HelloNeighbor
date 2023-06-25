//
//  StartViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/11.
//

import UIKit
import MessageUI


class StartViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        signupButton.layer.cornerRadius = 10
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func inquireButton(_ sender: Any) {
        //メールを送信できるかチェック
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
    }
    
    @IBAction func signupButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
