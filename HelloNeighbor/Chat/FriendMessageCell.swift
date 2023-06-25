import UIKit
import Nuke

protocol FriendMessageCellDelegate {
    func toFriendInfoFromXib(uid:String,user:User)
}

class FriendMessageCell: UITableViewCell {
    
    var friendMessageCellDelegate: FriendMessageCellDelegate?
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    var user:User!{
        didSet{
            if let url = URL(string: self.user.userImageUrl){
                Nuke.loadImage(with: url, into: userImageView)
            }else{
                userImageView.image = UIImage(named: "noImage")
            }
        }
    }
    
    var message:Message!{
        didSet{
            userImageView.layer.cornerRadius = 20
            userImageView.isUserInteractionEnabled = true
            userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedUserImage(_:))))
            MessageTextView.layer.cornerRadius =  10
            let message = message.message
            MessageTextView.text = message
            let witdh = estimateFrameForTextView(text: message).width + 20
            messageTextViewWidthConstraint.constant = witdh
            DateLabel.text = dateFormatterForDateLabel(date: self.message.createdAt.dateValue())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        MessageTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.link]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func tappedUserImage(_ sender: Any){
        friendMessageCellDelegate?.toFriendInfoFromXib(uid: message.uid, user: self.user)
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil)
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
    
}

