import UIKit

class MyMessageCell: UITableViewCell {
    
    var message: Message!{
        didSet{
            myMessageTextView.text = message.message
            let witdh = estimateFrameForTextView(text: message.message).width + 20
            myMessageTextViewWidthConstraint.constant = witdh
            myMessageTextView.layer.cornerRadius = 10
            myDateLabel.text = dateFormatterForDateLabel(date: self.message.createdAt.dateValue())
            if message.whetherRead == true
            {
                whetherReadLabel.isHidden = false
            }else{
                whetherReadLabel.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var whetherReadLabel: UILabel!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        myMessageTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.link]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 9999)
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

