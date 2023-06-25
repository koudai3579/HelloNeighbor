import Foundation
import Firebase

class Friend {
    let uid: String
    var allowedFriend: Bool
    var friendCanceled:Bool
    var chatRoomID:String
    var unsentMessage:String
    var lastMessageAt:Timestamp
    
    init(dic: [String: Any]) {
        self.uid = dic["uid"] as? String ?? ""
        self.chatRoomID = dic["chatRoomID"] as? String ?? ""
        self.allowedFriend = dic["allowedFriend"] as? Bool ?? false
        self.friendCanceled = dic["friendCanceled"] as? Bool ?? false
        self.unsentMessage = dic["unsentMessage"] as? String ?? ""
        self.lastMessageAt = dic["lastMessageAt"] as? Timestamp ?? Timestamp()
    }
}
