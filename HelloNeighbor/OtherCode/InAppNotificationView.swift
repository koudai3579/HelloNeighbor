import UIKit
import Nuke

class InAppNotificationView: UIView {
    
    var currentPositionY: CGFloat = 0
    let bannerHeight = CGFloat(60)
    let bannerMargin = CGFloat(12)
    var imageUrl:String!
    var sentence:String!
    var transitionDestination:String!
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var targetWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .flatMap { $0 }?
            .windows.first
    }
    
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapped))
    lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanned))
    
    init(imageUrl:String,sentence:String,transitionDestination:String) {
        super.init(frame: .zero)
        
        self.imageUrl = imageUrl
        self.sentence = sentence
        self.transitionDestination = transitionDestination
    
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        let nib = UINib(nibName: "InAppNotificationView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        userImageView.layer.cornerRadius = 25
        notificationLabel.text = sentence
        if let url = URL(string: imageUrl){
            Nuke.loadImage(with: url, into: userImageView)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showBanner() {
        guard let window = targetWindow else { return }
        let width = window.frame.width
        let height = bannerHeight + window.safeAreaInsets.top
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = CGRect(
            x: bannerMargin + window.safeAreaInsets.left,
            y: height - bannerHeight,
            width: width - ((bannerMargin * 2) + window.safeAreaInsets.left + window.safeAreaInsets.right),
            height: bannerHeight
        )
        self.setNeedsLayout()
        self.layoutIfNeeded()
        targetWindow?.addSubview(self)
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: 0, y: -frame.height)
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.addGestureRecognizer(self.panGesture)
            self.addGestureRecognizer(self.tapGesture)
        })
        countDownToCloseBanner()
    }
    
    func closeBanner() {
        bannerClosingTimer = nil
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.transform = .init(translationX: 0, y: -self.frame.height)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    @objc func didTapped(_ sender: UITapGestureRecognizer) {
        //タップ時の処理
        closeBanner()
    }
    
    @objc func didPanned(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            bannerClosingTimer = nil
            break
            
        case .changed:
            let point = sender.translation(in: self)
            guard currentPositionY + point.y <= 0 else { return }
            currentPositionY += point.y
            self.transform = .init(translationX: 0, y: currentPositionY)
            sender.setTranslation(.zero, in: self)
            
        case .ended, .cancelled:
            if (abs(currentPositionY) > bannerHeight / 2) {
                closeBanner()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                    self.currentPositionY = 0
                }
                countDownToCloseBanner()
            }
        default:break
        }
    }
    
    var bannerClosingTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    func countDownToCloseBanner() {
        bannerClosingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.closeBanner()
        }
    }
    
}

