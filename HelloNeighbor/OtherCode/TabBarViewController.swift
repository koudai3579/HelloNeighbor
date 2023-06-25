//
//  TabBarViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/05/31.
//

import UIKit
import Firebase

class TabBarViewController: UITabBarController {
    
    var finishedViewDidAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.finishedViewDidAppear = true
        }
    }
    
    //アプリ利用中に新規メッセージ受信→アプリ内通知バー表示
    private func checkNewMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("friends").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("friend情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach { (documentChange) in
                
                switch documentChange.type{
                case .added:
                    let dic = documentChange.document.data()
                    let friend = Friend.init(dic: dic)
                    
                    Firestore.firestore().collection("users").document(friend.uid).getDocument { (snapshot, err) in
                        if let err = err {
                            print("friend情報の取得に失敗しました。\(err)")
                            return
                        }
                        guard let dic = snapshot!.data() else {return}
                        let user = User.init(dic: dic)
                        user.chatRoomID = friend.chatRoomID
                        
                        Firestore.firestore().collection("chatRoom").document(friend.chatRoomID).collection("messages").addSnapshotListener { (snapshots, err) in
                            if let err = err{
                                print("chatRoom情報の取得に失敗しました。\(err)")
                                return
                            }
                            snapshots?.documentChanges.forEach { (documentChange) in
                                switch documentChange.type{
                                    
                                case .added:
                                    
                                    let dic = documentChange.document.data()
                                    let message = Message(dic: dic)
                                    if self.finishedViewDidAppear == false || uid == message.uid{return}
                                    
                                    InAppNotificationView(imageUrl: user.userImageUrl, sentence: "\(user.name)さんからメッセージが届きました！", transitionDestination: "").showBanner()
                                    
                                case .modified:break
                                case .removed:break
                                }
                            }
                        }
                    }
                    
                case .modified: break
                case .removed: break
                }
            }
        }
    }
    
    
}
