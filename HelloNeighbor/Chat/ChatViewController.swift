//
//  ChatViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/11.
//

import UIKit
import Firebase
import Nuke
import PKHUD
import SCLAlertView_Objective_C

private let cellId1 = "cellId1"
private let cellId2 = "cellId2"
private let cellId3 = "cellId3"
private let cellId4 = "cellId4"

class ChatViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,ChatInputAccessoryViewDelegate,FriendMessageCellDelegate {
    
    var initialChatTableViewFrameOriginY:CGFloat!
    var initialSendMessageViewFrameOriginY:CGFloat!
    var messages = [Message]()
    var chatRoomID: String!//画面遷移時にもらう
    var myInfo :User!//画面遷移時にもらう
    var partner:User!//画面遷移時にもらう
    private let inputAccessoryHeight: CGFloat = 90
    private let tableViewStartContentInset: UIEdgeInsets = .init(top: 10, left: 0, bottom: 60, right: 0)
    @IBOutlet weak var chatTableView: UITableView!
    private var safeAreaBottom: CGFloat { self.view.safeAreaInsets.bottom }
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView(chatRoomID: chatRoomID)
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: inputAccessoryHeight)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.partner.name
        chatTableView.contentInset = tableViewStartContentInset
        chatTableView.scrollIndicatorInsets = tableViewStartContentInset
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "FriendMessageCell", bundle: nil), forCellReuseIdentifier: cellId1)
        chatTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: cellId3)
        chatTableView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedTableView))
        chatTableView.addGestureRecognizer(tapGestureRecognizer)
        chatTableView.keyboardDismissMode = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        fetchMyInfo()
        fetchChatData()
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= inputAccessoryHeight { return }
            let bottom = keyboardFrame.height - safeAreaBottom
            var moveY = -(bottom - chatTableView.contentOffset.y)
            
            //最下部意外の時は少しずれるので微調整
            if chatTableView.contentOffset.y != -60 {
                moveY += 60
            }
            
            chatTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
            chatTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
            chatTableView.contentOffset = CGPoint(x: 0, y: moveY)
            
            
            if messages.count != 0{
                self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
        
    }
    
    @objc func keyboardWillHide() {
        chatTableView.contentInset = tableViewStartContentInset
        chatTableView.scrollIndicatorInsets = tableViewStartContentInset
    }
    
    func fetchMyInfo(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            self.myInfo = User.init(dic: dic!)
        }
    }
    
    private func fetchChatData(){
        
        messages.removeAll()
        Firestore.firestore().collection("chatRoom").document(self.chatRoomID).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if let err = err{
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach { (documentChange) in
                
                switch documentChange.type{
                    
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    
                    for element in self.messages{
                        if element.messageUid == message.messageUid{
                            return
                        }
                    }
                    
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                    
                    self.chatTableView.reloadData()
                    if self.messages.count != 0 {
                        self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    }
                    
                case .modified:self.fetchChatData()
                case .removed:break
                }
            }
        }
    }
    
    @objc func tappedUserImage(_ gesture:UITapGestureRecognizer){
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = self.partner
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cameraButtonAction() {
        
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
        alert.addButton("キャンセル", actionBlock: {
            
        })
        alert.showSuccess(self, title: "写真を送信", subTitle: nil, closeButtonTitle: nil, duration: 0)
        
    }
    
    //メッセージを送信
    func tappedSendButton(text: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let messageUid = NSUUID().uuidString
        let docData = [
            "uid": uid,
            "message":text,
            "imageUrl":"",
            "createdAt": Timestamp(),
            "whetherRead":false,
            "messageUid":messageUid,
        ] as [String : Any]
        Firestore.firestore().collection("chatRoom").document(chatRoomID).collection("messages").document(messageUid).setData(docData) { (err) in
            if let err = err{
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            self.updateLastMessageTime()
        }
    }
    
    //画像を送信
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true)
        
        var  messageImage:UIImage!
        guard let uid = Auth.auth().currentUser?.uid else {return}
        if let editImage = info[.editedImage] as? UIImage {
            messageImage = editImage
        }else if let originalImage = info[.originalImage] as? UIImage{
            messageImage = originalImage
        }
        guard let uploadProfileImage = messageImage?.jpegData(compressionQuality: 0.5) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_image").child(fileName)
        
        storageRef.putData(uploadProfileImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのダウンロードに失敗しました。\(err)")
                    return
                }
                let messageImageUrl = url?.absoluteString
                let messageUid = NSUUID().uuidString
                
                let docData = [
                    "uid": uid,
                    "messageUid": messageUid,
                    "message":"",
                    "imageUrl": messageImageUrl!,
                    "createdAt": Timestamp(),
                    "whetherRead":false,
                ] as [String : Any]
                
                Firestore.firestore().collection("chatRoom").document(self.chatRoomID).collection("messages").document(messageUid).setData(docData) { (err) in
                    if let err = err{
                        print("メッセージ情報の取得に失敗しました。\(err)")
                        return
                    }
                    self.updateLastMessageTime()
                }
            }
        }
    }
    
    @objc func tappedTableView(gestureRecognizer: UITapGestureRecognizer) {
        chatInputAccessoryView.hideTextKeyboard()
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) == true{
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ja_JP")
        }else{
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ja_JP")
        }
        return formatter.string(from: date)
    }
    
    private func MarkAsRead(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        for message in messages {
            if message.uid != uid{
                Firestore.firestore().collection("chatRoom").document(self.chatRoomID).collection("messages").document(message.messageUid).updateData([
                    "whetherRead": true
                ]) { err in
                    if let err = err {
                        print("情報を更新できませんでした。: \(err)")
                        return
                    }
                }
            }
        }
    }
    
    //delegateMethod
    func toFriendInfoFromXib(uid:String,user:User) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateLastMessageTime(){
        
        Firestore.firestore().collection("users").document(self.myInfo.uid).collection("friends").document(self.partner.uid).updateData([
            "lastMessageAt": Timestamp(),
        ]) { err in
            if let err = err {
                print("ラストメッセージの更新に失敗しました",err)
                return
            }
            Firestore.firestore().collection("users").document(self.partner.uid).collection("friends").document(self.myInfo.uid).updateData([
                "lastMessageAt": Timestamp(),
            ]) { err in
                if let err = err {
                    print("ラストメッセージの更新に失敗しました",err)
                    return
                }
            }
        }
    }
}

extension ChatViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let uid = Auth.auth().currentUser?.uid else {return 200}
        //セル1（自分以外が送ったメッセージテキスト）
        if messages[indexPath.row].uid != uid && messages[indexPath.row].message != ""{
            chatTableView.estimatedRowHeight = 20
            return UITableView.automaticDimension
            
            //セル2（自分以外が送った画像）
        }else if messages[indexPath.row].uid != uid && messages[indexPath.row].message == ""{
            return 120
            
            //セル3（自分が送ったメッセージテキスト）
        }else if messages[indexPath.row].uid == uid && messages[indexPath.row].message != ""{
            chatTableView.estimatedRowHeight = 20
            return UITableView.automaticDimension
            
            //セル4（自分が送った画像）
        }else if messages[indexPath.row].uid == uid && messages[indexPath.row].message == ""{
            return 120
        }
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let uid = Auth.auth().currentUser?.uid
        //セル1（自分以外が送ったメッセージテキスト）
        if messages[indexPath.row].uid != uid && messages[indexPath.row].message != ""{
            let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath) as! FriendMessageCell
            
            cell.friendMessageCellDelegate = self
            cell.message = self.messages[indexPath.row]
            cell.user = self.partner
            return cell
            
            //セル2（自分以外が送った画像）
        }else if messages[indexPath.row].uid != uid && messages[indexPath.row].message == ""{
            let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath)
            let userImage = cell.contentView.viewWithTag(1) as! UIImageView
            userImage.layer.cornerRadius = 20
            userImage.isUserInteractionEnabled = true
            userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedUserImage(_:))))
            
            if let url = URL(string: self.partner.userImageUrl){
                Nuke.loadImage(with: url, into: userImage)
            }else{
                userImage.image = UIImage(named: "noImage")
            }
            
            let messageImage = cell.contentView.viewWithTag(2) as! UIImageView
            messageImage.layer.cornerRadius = 8
            messageImage.isUserInteractionEnabled = true
            
            if let url = URL(string: self.messages[indexPath.row].imageUrl){
                Nuke.loadImage(with: url, into: messageImage)
            }else{
                messageImage.image = UIImage(named: "noImage")
            }
            
            let dateLabel = cell.contentView.viewWithTag(4) as! UILabel
            dateLabel.text = dateFormatterForDateLabel(date: messages[indexPath.row].createdAt.dateValue())
            return cell
            
            //セル3（自分が送ったメッセージテキスト）
        }else if messages[indexPath.row].uid == uid && messages[indexPath.row].message != ""{
            let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId3, for: indexPath) as! MyMessageCell
            cell.message =  messages[indexPath.row]
            return cell
            
            //セル4（自分が送った画像）
        }else if messages[indexPath.row].uid == uid && messages[indexPath.row].message == ""{
            let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId4, for: indexPath)
            let messageImage = cell.contentView.viewWithTag(2) as! UIImageView
            messageImage.layer.cornerRadius = 8
            messageImage.isUserInteractionEnabled = true
            
            if let url = URL(string: self.messages[indexPath.row].imageUrl){
                Nuke.loadImage(with: url, into: messageImage)
            }else{
                messageImage.image = UIImage(named: "noImage")
            }
            
            let dateLabel = cell.contentView.viewWithTag(4) as! UILabel
            dateLabel.text = dateFormatterForDateLabel(date: messages[indexPath.row].createdAt.dateValue())
            let whetherReadLabel = cell.contentView.viewWithTag(5) as! UILabel
            if messages[indexPath.row].whetherRead == true
            {
                whetherReadLabel.isHidden = false
            }else{
                whetherReadLabel.isHidden = true
            }
            return cell
            
        }
        let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath)
        return cell
        
    }
}
