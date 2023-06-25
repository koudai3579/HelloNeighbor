import UIKit
import Firebase
import PKHUD

protocol ChatInputAccessoryViewDelegate: AnyObject {
    func tappedSendButton(text: String)
    func cameraButtonAction()
}

class ChatInputAccessoryView: UIView,UITextViewDelegate {
    
    var partnerUid:String!
    var chatRoomID:String!
    var lastUnsentMessage:String!
    var myInfo:User!
    weak var delegate: ChatInputAccessoryViewDelegate?
    @IBOutlet weak var chatTextView: PlaceTextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var sendImageButton: UIButton!
    
    init(chatRoomID: String) {
        super.init(frame: .zero)
        self.chatRoomID = chatRoomID
        
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        
        sendImageButton.setTitle("", for: .normal)
        sendMessageButton.setTitle("", for: .normal)
        chatTextView.layer.cornerRadius = 8
        chatTextView.layer.borderColor = UIColor.gray.cgColor
        chatTextView.layer.borderWidth = 1
        chatTextView.placeHolder = "Aa"
        sendMessageButton.isEnabled = false
        chatTextView.isScrollEnabled = false
        chatTextView.delegate = self
        autoresizingMask = .flexibleHeight
        fetchMyInfo()
        fetchUnsentMessage()
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        chatTextView.resignFirstResponder()
        delegate?.cameraButtonAction()
        sendImageButton.isEnabled = false
        chatTextView.isUserInteractionEnabled = false
    }
    
    @IBAction func tappedSendButton(_ sender: Any) {
        chatTextView.resignFirstResponder()
        guard let text = chatTextView.text else { return }
        
        chatTextView.text = ""
        chatTextView.placeHolder = "Aa"
        sendMessageButton.isEnabled = false
        delegate?.tappedSendButton(text: text)
        resetUnsentMessage(text: text)
        
    }
    
    func hideTextKeyboard(){
        chatTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let text = chatTextView.text else {
            chatTextView.placeHolder = "Aa"
            return}
        
        updateUnsentMessage(text:text)
        
        if text.isEmpty {
            sendMessageButton.isEnabled = false
        } else {
            sendMessageButton.isEnabled = true
        }
        
        if text.count > 100 {
            // 最大文字数超えた場合は切り捨て
            chatTextView.text = String(text.prefix(100))
            textCountLabel.textColor = .red
            textCountLabel.text = "100/100"
        }else{
            textCountLabel.textColor = .darkGray
            textCountLabel.text = "\(text.count)/100"
        }
    }
    
    private func fetchMyInfo(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { [self](snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            self.myInfo = User(dic: dic!)
        }
    }
    
    private func fetchUnsentMessage(){
        
        guard let myUid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("chatRoom").document(self.chatRoomID).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let chatRoom = ChatRoom.init(dic: dic!)
            let chatMembers = chatRoom.memebers
            
            for chatMember in chatMembers {
                
                Firestore.firestore().collection("users").document(chatMember).getDocument {(snapshot, err ) in
                    if let err = err{
                        print("ログインユーザーの取得に失敗しました。\(err)")
                        return
                    }
                    let dic = snapshot?.data()
                    let member = User.init(dic: dic!)
                    
                    if myUid != member.uid {
                        self.partnerUid = member.uid
                        Firestore.firestore().collection("users").document(myUid).collection("friends").document(member.uid).getDocument {(snapshot, err ) in
                            if let err = err{
                                print("ドキュメントの取得に失敗しました。\(err)")
                                return
                            }
                            
                            guard let dic = snapshot?.data() else {return}
                            self.lastUnsentMessage = Friend.init(dic: dic).unsentMessage
                            if self.lastUnsentMessage != ""{
                                self.chatTextView.placeHolder = ""
                                self.chatTextView.text = self.lastUnsentMessage
                                self.sendMessageButton.isEnabled = true
                                self.textCountLabel.textColor = .darkGray
                                self.textCountLabel.text = "\(self.lastUnsentMessage.count)/100"
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateUnsentMessage(text:String){
        Firestore.firestore().collection("users").document(myInfo.uid).collection("friends").document(partnerUid).updateData([
            "unsentMessage": text,
        ]) { err in
            if let err = err {
                print("アップデートに失敗しました。: \(err)")
                return
            }
        }
    }
    
    private func resetUnsentMessage(text:String){
        Firestore.firestore().collection("users").document(myInfo.uid).collection("friends").document(partnerUid).updateData([
            "unsentMessage": "",
        ]) { err in
            if let err = err {
                print("アップデートに失敗しました。: \(err)")
                return
            }
        }
    }
    
}
