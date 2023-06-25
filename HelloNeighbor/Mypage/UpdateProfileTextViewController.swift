//
//  UpdateProfileTextViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/20.
//

import UIKit
import Firebase

class UpdateProfileTextViewController: UIViewController,UITextViewDelegate {
    
    var profileText:String!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var profileTextView: PlaceTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "自己紹介文"
        profileTextView.delegate = self
        profileTextView.layer.borderColor = UIColor.lightGray.cgColor
        profileTextView.layer.borderWidth = 1
        profileTextView.layer.cornerRadius = 5
        profileTextView.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 10
        calcProfileTextCount()
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        profileTextView.inputAccessoryView = toolbar
        
    }
    
    private func calcProfileTextCount(){
        if profileText != ""{
            profileTextView.text = profileText
            profileTextView.textColor = .black
            
            if profileText.count > 1000{
                charactersCountLabel.text = "\(profileText.count)/500"
                charactersCountLabel.textColor = .red
                saveButton.isEnabled = true
            }else{
                charactersCountLabel.text = "\(profileText.count)/500"
                charactersCountLabel.textColor = .darkGray
                saveButton.isEnabled = true
            }
            
        }else{
            charactersCountLabel.text = "0/500"
            profileTextView.textColor = .lightGray
            profileTextView.text = "未入力"
        }
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let charactersCount = profileTextView.text?.count
        if charactersCount ?? 0 > 500{
            charactersCountLabel.text = "\(charactersCount!)/500"
            charactersCountLabel.textColor = .red
            saveButton.isEnabled = true
        }else{
            charactersCountLabel.text = "\(charactersCount!)/500"
            charactersCountLabel.textColor = .darkGray
            saveButton.isEnabled = true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if profileTextView.textColor == .lightGray{
            profileTextView.text = ""
            profileTextView.textColor = .black
            charactersCountLabel.text = "0/500"
        }
        return true
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).updateData([
            "profileText": profileTextView.text!,
        ]) { err in
            if let err = err {
                print("情報を更新できませんでした。: \(err)")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
