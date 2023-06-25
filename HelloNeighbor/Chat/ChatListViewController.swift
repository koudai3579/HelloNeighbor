//
//  ChatListViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/05/31.
//

import UIKit
import Firebase
import PKHUD
import Nuke

private let cellId = "cellId"

class ChatListViewController: UIViewController {
        
    var users = [User]()
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChatList()
    }
    
    private func fetchChatList(){
        
        users.removeAll()
        users = [User]()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("friends").addSnapshotListener { (snapshots, err) in
            if let err = err{
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
            guard (snapshots?.documents) != nil else {return}
            snapshots?.documentChanges.forEach { (documentChange) in
                switch documentChange.type{
                    
                case .added:
                    let dic = documentChange.document.data()
                    let friend = Friend.init(dic: dic)
                    Firestore.firestore().collection("users").document(documentChange.document.documentID).getDocument {(snapshot, err ) in
                        if let err = err{
                            print("ユーザーの取得に失敗しました。\(err)")
                            return
                        }
                        
                        guard let dic = snapshot?.data() else{return}
                        let user = User.init(dic: dic)
                        user.chatRoomID = friend.chatRoomID
                        user.lastMessageAt = friend.lastMessageAt
                        
                        Firestore.firestore().collection("chatRoom").document(user.chatRoomID).collection("messages").addSnapshotListener { (snapshots, err) in
                            if let err = err{
                                print("メッセージ情報の取得に失敗しました。\(err)")
                                return
                            }
                            //メッセージドキュメントが存在する場合
                            snapshots?.documentChanges.forEach { (documentChange) in
                                switch documentChange.type{
                                    
                                case .added:
                                    let dic = documentChange.document.data()
                                    let message = Message(dic: dic)
                                    user.messages.append(message)
                                    if message.whetherRead == false && message.uid == user.uid{
                                        user.notReadMessageCount += 1
                                    }
                                    
                                    user.messages.sort { (m1, m2) -> Bool in
                                        let m1Date = m1.createdAt.dateValue()
                                        let m2Date = m2.createdAt.dateValue()
                                        return m1Date < m2Date
                                    }
                                    
                                case .modified:break
                                case .removed:break
                                }
                                self.users.append(user)
                                self.users.sort { (m1, m2) -> Bool in
                                    let m1 = m1.lastMessageAt.dateValue()
                                    let m2 = m2.lastMessageAt.dateValue()
                                    return m1 > m2
                                }
                            }
                            
                            self.chatListTableView.reloadData()
                        }
                    }
                    
                case .modified:break
                case .removed:break
                    
                }
            }
        }
    }
    
    
}

extension ChatListViewController: UITableViewDelegate,UITableViewDataSource {

//横スライドで削除を選択した時の挙動
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let uid = Auth.auth().currentUser?.uid
        
        let userImage = cell.contentView.viewWithTag(1) as! UIImageView
        userImage.backgroundColor = UIColor.blue
        userImage.layer.cornerRadius = 30
        if let url = URL(string: self.users[indexPath.row].userImageUrl){
            Nuke.loadImage(with: url, into: userImage)
        }
        let userLabel = cell.contentView.viewWithTag(2) as! UILabel
        userLabel.text = users[indexPath.row].name
        
        let lastMessageLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        if users[indexPath.row].messages.last?.message != ""{
            lastMessageLabel.text = users[indexPath.row].messages.last?.message
            lastMessageLabel.textColor = .darkGray
        }else{
            lastMessageLabel.text = "写真を送信しました！"
            lastMessageLabel.textColor = .darkGray
        }
        
        let newMessageCountLabel = cell.contentView.viewWithTag(4) as! UILabel
        newMessageCountLabel.layer.cornerRadius = 20
        if users[indexPath.row].messages.last?.uid == uid {
            newMessageCountLabel.isHidden = true
        }else{
            newMessageCountLabel.isHidden = false
            newMessageCountLabel.text =  String(users[indexPath.row].notReadMessageCount)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
        as! ChatViewController
        vc.chatRoomID = self.users[indexPath.row].chatRoomID
        vc.partner = self.users[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
