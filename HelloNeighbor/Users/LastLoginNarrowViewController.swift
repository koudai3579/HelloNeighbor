import UIKit

private let cellId = "cellId"

class LastLoginNarrowViewController: UIViewController {
    
    var whetherRecruitmentNarrow = false
    var selecteLlogins = [String]()
    let logins = ["1時間以内","12時間以内","24時間以内","3日前以内","1週間以内","1週間以上前"]
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var logingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "最終ログイン"
        resetButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
        logingTableView.delegate = self
        logingTableView.dataSource = self
    }
    
    @IBAction func saveButton(_ sender: Any) {
            let nav = self.navigationController
            let vc = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! NarrowUserViewController
            vc.logins = selecteLlogins
            _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        selecteLlogins = [String]()
        logingTableView.reloadData()
    }
    
}

extension LastLoginNarrowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = logingTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let loginLabel = cell.contentView.viewWithTag(1) as! UILabel
        loginLabel.text = logins[indexPath.row]
        let selectedImage = cell.contentView.viewWithTag(2) as! UIImageView
        
        if selecteLlogins.contains(logins[indexPath.row]) == true {
            selectedImage.image = UIImage(systemName: "checkmark.circle.fill")
        }else{
            selectedImage.image = UIImage(systemName: "circle")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let  selectImage = logingTableView.cellForRow(at: indexPath)?.contentView.viewWithTag(2) as! UIImageView
        if selectImage.image == UIImage(systemName: "circle"){
            selectImage.image = UIImage(systemName: "checkmark.circle.fill")
            selecteLlogins.append(logins[indexPath.row])
        }else{
            selectImage.image = UIImage(systemName: "circle")
            selecteLlogins.removeAll(where: {$0 == logins[indexPath.row]})
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
