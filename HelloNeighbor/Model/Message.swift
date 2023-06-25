import Foundation
import Firebase

class Message {
    let message: String
    let uid: String
    let createdAt: Timestamp
    let imageUrl:String
    let whetherRead:Bool
    let messageUid:String
    
    init(dic :[String:Any]){
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.messageUid = dic["messageUid"] as? String ?? ""
        self.imageUrl = dic["imageUrl"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.whetherRead = dic["whetherRead"] as? Bool ?? false
    }
}
