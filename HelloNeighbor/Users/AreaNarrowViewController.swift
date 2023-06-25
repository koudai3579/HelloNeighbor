
import UIKit
private let cellId = "cellId"

class AreaNarrowViewController: UIViewController {
    
    var whetherRecruitmentNarrow = false
    var selectedAreas = [String]()
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var areaTableView: UITableView!
    let areas:[String] = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県","海外"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "居住地"
        areaTableView.dataSource = self
        areaTableView.delegate = self
        resetButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let nav = self.navigationController
        let vc = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! NarrowUserViewController
        vc.areas = selectedAreas
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        selectedAreas = [String]()
        areaTableView.reloadData()
    }
}

extension AreaNarrowViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = areaTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let areaLabel = cell.contentView.viewWithTag(1) as! UILabel
        areaLabel.text = areas[indexPath.row]
        let selectedImage = cell.contentView.viewWithTag(2) as! UIImageView
        
        if selectedAreas.contains(areas[indexPath.row]) == true {
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
        let  selectImage = areaTableView.cellForRow(at: indexPath)?.contentView.viewWithTag(2) as! UIImageView
        
        if selectImage.image == UIImage(systemName: "circle"){
            selectImage.image = UIImage(systemName: "checkmark.circle.fill")
            selectedAreas.append(areas[indexPath.row])
        }else{
            selectImage.image = UIImage(systemName: "circle")
            selectedAreas.removeAll(where: {$0 == areas[indexPath.row]})
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
