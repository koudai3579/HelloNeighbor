//
//  ProfileViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/11.
//

import UIKit
import Nuke
import Firebase

class ProfileViewController: UIViewController {
    
    var user:User!
    @IBOutlet weak var ageAreaLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var toChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toChatButton.layer.cornerRadius = 10
        profileTextView.isEditable = false
        nameLabel.text = user.name
        ageAreaLabel.text = "\(user.area)・\(user.age)"
        profileTextView.layer.borderColor = UIColor.darkGray.cgColor
        profileTextView.layer.borderWidth = 0.5
        profileTextView.layer.cornerRadius = 5
        if user.profileText == ""{
            profileTextView.text = "プロフィール文章が設定されていません。"
        }else{
            profileTextView.text = user.profileText
        }
        if let url = URL(string: user.userImageUrl){
            Nuke.loadImage(with: url, into: userImageView)
            self.userImageView.layer.cornerRadius = 10
        }
    }
    
    @IBAction func toChatButton(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("friends").document(self.user.uid).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            //既にchatRoom作成済み
            if snapshot?.data() != nil{
                let friend = Friend.init(dic: (snapshot?.data())!)
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.chatRoomID = friend.chatRoomID
                vc.partner = self.user
                self.navigationController?.pushViewController(vc, animated: true)
                
                //chatRoom未作成
            }else{
                self.createChatRoom()
            }
            
        }
    }
    
    private func createChatRoom(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let chatRoomID = NSUUID().uuidString
        //①自分の情報をUPDATE
        
        let docData = [
            "chatRoomID": chatRoomID,
            "matchedAt":Timestamp(),
            "lastMessageAt":Timestamp(),
        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(uid).collection("friends").document(user.uid).setData(docData) { err in
            if let err = err {
                print("いいねに失敗しました。\(err)")
                return
            }
            //②相手の情報をUPDATE
            Firestore.firestore().collection("users").document(self.user.uid).collection("friends").document(uid).setData(docData) { err in
                if let err = err {
                    print("いいねに失敗しました。\(err)")
                    return
                }
                //③チャットルームを作成し画面遷移
                let chatRoomData = [
                    "chatRoomID": chatRoomID,
                    "latestMessageId":"",
                    "createdAt": Timestamp(),
                    "memebers":[uid,self.user.uid]
                    
                ] as [String : Any]
                Firestore.firestore().collection("chatRoom").document(chatRoomID).setData(chatRoomData) { (err) in
                    if let err = err {
                        print("Firestoreへの保存に失敗しました。\(err)")
                        return
                    }
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    vc.chatRoomID = chatRoomID
                    vc.partner = self.user
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
        }
    }
    
}
