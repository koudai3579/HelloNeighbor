//
//  NarrowUserContainerTableViewController.swift
//  SideLink
//
//  Created by Koudai Okamura on 2022/11/07.
//

import UIKit

class NarrowUserContainerTableViewController: UITableViewController,UITextFieldDelegate {
    
    var areas = [String]()
    var ages = [String]()
    var logins = [String]()
    var Within1WeekRegistration = false
    var exsistProfieText = false
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var profileTextSwitch: UISwitch!
    @IBOutlet weak var within1WeekRegistrationSwitch: UISwitch!
    @IBOutlet var narrowUserContentTableView: UITableView!
    @IBOutlet weak var loginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        narrowUserContentTableView.delegate = self
        narrowUserContentTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ages != []{
            let agesText = ages.joined(separator: ",")
            
            ageLabel.text = agesText
            ageLabel.textColor = .black
        }else{
            ageLabel.text = "こだわらない"
            ageLabel.textColor = .lightGray
        }
        
        if areas != []{
            let areasText = areas.joined(separator: ",")
            
            areaLabel.text = areasText
            areaLabel.textColor = .black
        }else{
            areaLabel.text = "こだわらない"
            areaLabel.textColor = .lightGray
        }
    
        if logins != []{
            let loginsText = logins.joined(separator: ",")
            loginLabel.text = loginsText
            loginLabel.textColor = .black
        }else{
            loginLabel.text = "こだわらない"
            loginLabel.textColor = .lightGray
        }
        
        if Within1WeekRegistration == true{
            within1WeekRegistrationSwitch.isOn = true
        }else{
            within1WeekRegistrationSwitch.isOn = false
        }
        
        if exsistProfieText == true{
            profileTextSwitch.isOn = true
        }else{
            profileTextSwitch.isOn = false
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AgeNarrowViewController") as! AgeNarrowViewController
            vc.ages = self.ages
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        if indexPath.section == 0 && indexPath.row == 1{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AreaNarrowViewController") as! AreaNarrowViewController
            vc.selectedAreas = areas
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        
        if indexPath.section == 0 && indexPath.row == 2{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LastLoginNarrowViewController") as! LastLoginNarrowViewController
            vc.selecteLlogins = logins
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func tappedTableView(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        narrowUserContentTableView.scrollToRow(at: IndexPath(row: 0, section: 2),at: UITableView.ScrollPosition.bottom, animated: true)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardHeight + 0 )
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func within1WeekRegistrationSwitch(_ sender: Any) {
        if ( (sender as AnyObject).isOn ) {
            Within1WeekRegistration = true
        } else {
            Within1WeekRegistration = false
        }
        let parent = self.parent as! NarrowUserViewController
        parent.Within1WeekRegistration = Within1WeekRegistration
    }
    
    @IBAction func profileTextSwitch(_ sender: Any) {
        if ( (sender as AnyObject).isOn ) {
            exsistProfieText = true
        } else {
            exsistProfieText = false
        }
        let parent = self.parent as! NarrowUserViewController
        parent.exsistProfieText = exsistProfieText
    }
    

}
