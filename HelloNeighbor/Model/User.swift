import Foundation
import Firebase

class User {
    
    let uid: String
    var name: String
    var userId :String
    var userImageUrl :String
    var age :String
    var area:String
    var profileText :String
    var createdAt :Timestamp
    var lastLogin:Timestamp
    var blockUserUidList = [String]()
    var chatRoomID :String
    var latitude: Double
    var longitude: Double
    var messages = [Message]()
    var notReadMessageCount:Int!
    var lastMessageAt:Timestamp
    
    init(dic: [String: Any]) {
    
        self.name = dic["name"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.userId = dic["userId"] as? String ?? ""
        self.userImageUrl = dic["userImageUrl"] as? String ?? ""
        self.age = dic["age"] as? String ?? ""
        self.area = dic["area"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.lastLogin = dic["lastLogin"] as? Timestamp ?? Timestamp()
        self.blockUserUidList = dic["blockUserUidList"] as? [String] ?? [""]
        self.chatRoomID = dic["chatRoomId"] as? String ?? ""
        self.profileText = dic["profileText"] as? String ?? ""
        self.latitude = dic["latitude"] as? Double ?? 0
        self.longitude = dic["longitude"] as? Double ?? 0
        self.lastMessageAt = dic["lastMessageAt"] as? Timestamp ?? Timestamp()

    }
}
