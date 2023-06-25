import UIKit
private let cellId = "cellId"

class AgeNarrowViewController: UIViewController{
        
    var whetherRecruitmentNarrow = false
    var ages = [String]()
    let numbers: [Int] = Array(17...99)
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var ageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "年齢"
        ageTableView.dataSource = self
        ageTableView.delegate = self
        resetButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
    }
    
    @IBAction func resetButton(_ sender: Any) {
        ages = [String]()
        ageTableView.reloadData()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let nav = self.navigationController
        let vc = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! NarrowUserViewController
        vc.ages = ages
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension AgeNarrowViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ageTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let areaLabel = cell.contentView.viewWithTag(1) as! UILabel
        areaLabel.text = "\(numbers[indexPath.row])歳"
        let selectImage = cell.contentView.viewWithTag(2) as! UIImageView
        
        if ages.contains("\(numbers[indexPath.row])歳") == true {
            selectImage.image = UIImage(systemName: "checkmark.circle.fill")
        }else{
            selectImage.image = UIImage(systemName: "circle")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let  selectImage = ageTableView.cellForRow(at: indexPath)?.contentView.viewWithTag(2) as! UIImageView
        
        if selectImage.image == UIImage(systemName: "circle"){
            selectImage.image = UIImage(systemName: "checkmark.circle.fill")
            ages.append("\(numbers[indexPath.row])歳")
            
        }else{
            selectImage.image = UIImage(systemName: "circle")
            ages.removeAll(where: {$0 == "\(numbers[indexPath.row])歳"})

        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
    
