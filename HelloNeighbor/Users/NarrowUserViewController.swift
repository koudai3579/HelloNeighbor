
import UIKit

class NarrowUserViewController: UIViewController {
    
    var areas = [String]()
    var ages = [String]()
    var logins = [String]()
    var Within1WeekRegistration = false
    var exsistProfieText = false
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.layer.cornerRadius = 10
        resetButton.layer.cornerRadius = 10
        ages = UserDefaults.standard.stringArray(forKey: {"ages"}()) ?? [String]()
        areas = UserDefaults.standard.stringArray(forKey: {"areas"}()) ?? [String]()
        logins = UserDefaults.standard.stringArray(forKey: {"logins"}()) ?? [String]()
        Within1WeekRegistration = UserDefaults.standard.bool(forKey: {"Within1WeekRegistration"}())
        exsistProfieText = UserDefaults.standard.bool(forKey: {"exsistProfieText"}())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let child = self.children[0] as! NarrowUserContainerTableViewController
        child.ages = ages
        child.areas = areas
        child.logins = logins
        child.exsistProfieText = exsistProfieText
        child.Within1WeekRegistration = Within1WeekRegistration
    }
    
    @IBAction func resetButton(_ sender: Any) {
        //①検索データの初期化
        areas = [String]()
        ages = [String]()
        logins = [String]()
        Within1WeekRegistration = false
        exsistProfieText = false
        //②Container内の初期化
        let child = self.children[0] as! NarrowUserContainerTableViewController
        child.ages = ages
        child.areas = areas
        child.logins = logins
        child.exsistProfieText = exsistProfieText
        child.Within1WeekRegistration = Within1WeekRegistration
        child.viewWillAppear(true)
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        UserDefaults.standard.set(ages, forKey: "ages")
        UserDefaults.standard.set(areas, forKey: "areas")
        UserDefaults.standard.set(logins, forKey: "logins")
        UserDefaults.standard.set(exsistProfieText, forKey: "exsistProfieText")
        UserDefaults.standard.set(Within1WeekRegistration, forKey: "Within1WeekRegistration")
        
        let nav = self.navigationController
        let vc = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! UsersViewController
        vc.executionNarrowUser = true
        _ = navigationController?.popViewController(animated: true)
    }
    
}


