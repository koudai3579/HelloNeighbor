import Foundation
import Firebase

class ChatRoom {
    
    var memebers: [String]
    let createdAt: Timestamp
    let chatRoomID:String
    var messages = [Message]()
        
    init(dic: [String: Any]) {
        self.memebers = dic["memebers"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.chatRoomID = dic["chatRoomID"] as? String ?? ""
        self.messages = dic["messages"] as? [Message] ?? [Message]()
    }
    
}
