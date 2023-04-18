//
//  SettingVC.swift
//  Metastones
//
//  Created by Sonya Hew on 13/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol SettingDelegate: class {
    func updateToggleValue(index: Int, value: Bool)
}

class SettingVC: UIViewController {
    
    let appData = AppData.shared
    let popup = PopupManager()
    let profileViewModel = ProfileViewModel()

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    
    var headerTitles = [kLb.notifications.localized.capitalized, kLb.language.localized.capitalized, kLb.legal.localized.capitalized]
    var titles = [[kLb.receive_notifications.localized], [kLb.change_language.localized],
                  [kLb.terms_and_conditions.localized.capitalized,
                  kLb.disclaimer.localized.capitalized,
                  kLb.privacy_policy.localized.capitalized,
                  kLb.return_and_refund_policy.localized.capitalized,
                  kLb.shipping.localized.capitalized]]
    var haveLanguage: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        lbTitle.text = kLb.setting.localized.capitalized
        btnLogout.setTitle(kLb.logout.localized, for: .normal)
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        appVersion.text = "v\(version ?? "")(\(buildNumber ?? ""))"
        
        setupData()
    }
    
    func setupData() {
        LoginViewModel().getLanguage { (proceed, data) in
            if proceed {
                if data?.data?.language?.count ?? 0 <= 1 {
                    self.haveLanguage = false
                    self.headerTitles.remove(at: 1)
                    self.titles.remove(at: 1)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionFooterHeight = 0.01
        
        tableView.register(SettingTVC.self, forCellReuseIdentifier: "settingTVC")
        tableView.register(SettingTVHC.self, forCellReuseIdentifier: "settingTVHC")
    }
    
    @IBAction func logoutHandler(_ sender: Any) {
        popup.showAlert(destVC: popup.getLogoutPopup(title: "\(kLb.logout.localized)?")) { (btnTitle) in
            if btnTitle == kLb.ok.localized {
                self.profileViewModel.getSessionId { (proceed, data) in
                    if proceed {
                        self.appData.removeAppData()
                        self.navigationController?.setViewControllers([getVC(sb: "Landing", vc: "MenuVC")], animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingVC: SettingDelegate {
    func updateToggleValue(index: Int, value: Bool) {
        if index == 0 {
            profileViewModel.updateProfile(notification: value ? "1" : "0") { (proceed, data) in
                if proceed {
                    self.tableView.reloadSections(IndexSet(integer: index), with: .none)
                }
            }
        }
    }
}

extension SettingVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "settingTVHC") as! SettingTVHC
        header.lbTitle.text = headerTitles[section].capitalized
        header.awakeFromNib()
        return header.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingTVC") as! SettingTVC
        cell.lbTitle.text = titles[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.tag = indexPath.section
            cell.delegate = self
            cell.toggle.isOn = appData.profile?.profile?.notification == 1
            cell.setupAsSwitch()
        } else {
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "arrow-next.png"))
        }
        cell.awakeFromNib()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            return
            
        } else if indexPath.section == 1 && haveLanguage {
            let langVC = getVC(sb: "Main", vc: "LanguageVC") as! LanguageVC
            langVC.delegate = self
            langVC.modalPresentationStyle = .overFullScreen
            present(langVC, animated: true)
            
        } else {
            var urlString = ""
            var htmlString = ""
            
            switch indexPath.row {
            case 0: //tnc
                urlString = appData.appSetting?.terms?.url ?? ""
                htmlString = appData.appSetting?.terms?.htmlContent ?? ""
                
            case 1: //disclaimer
                urlString = appData.appSetting?.disclaimer?.url ?? ""
                htmlString = appData.appSetting?.disclaimer?.htmlContent ?? ""
                
            case 2: //privacy policy
                urlString = appData.appSetting?.privacyPolicy?.url ?? ""
                htmlString = appData.appSetting?.privacyPolicy?.htmlContent ?? ""
                
            case 3: //return refund
                urlString = appData.appSetting?.returnPolicy?.url ?? ""
                htmlString = appData.appSetting?.returnPolicy?.htmlContent ?? ""
                
            case 4: //shipping
                urlString = appData.appSetting?.shippingGuide?.url ?? ""
                htmlString = appData.appSetting?.shippingGuide?.htmlContent ?? ""
            default:
                print("error")
            }
            
            let webVC = getVC(sb: "Landing", vc: "WebVC") as! WebVC
            webVC.strUrl = urlString
            webVC.strHtml = htmlString
            webVC.vcTitle = titles[indexPath.section][indexPath.row]
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
}

extension SettingVC: LanguageVCDelegate {
    func langUpdated() {
        self.navigationController?.setViewControllers([getVC(sb: "Landing", vc: "MenuVC")], animated: true)
    }
}


//MARK:- SettingTVC
class SettingTVC: UITableViewCell {
    
    var lbTitle: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 15)
        lb.textColor = UIColor(hex: 0x2E2E2E)
        return lb
    }()
    
    weak var delegate : SettingDelegate?
    var toggle: UISwitch = UISwitch()
    
    override func awakeFromNib() {
        backgroundColor = .white
        contentView.addSubview(lbTitle)
        contentView.backgroundColor = .white
        lbTitle.translatesAutoresizingMaskIntoConstraints = false
        lbTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        lbTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    func setupAsSwitch() {
        selectionStyle = .none
        toggle.onTintColor = UIColor(hex: 0x2699FB)
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        accessoryView = toggle
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        delegate?.updateToggleValue(index:self.tag, value: mySwitch.isOn)
    }
}

//MARK:- SettingTVHC
class SettingTVHC: UITableViewCell {
    
    var lbTitle: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12)
        lb.textColor = .black
        return lb
    }()
    
    weak var delegate : SettingDelegate?
    
    override func awakeFromNib() {
        contentView.addSubview(lbTitle)
        contentView.backgroundColor = UIColor(hex: 0xE3E3E3)
        lbTitle.translatesAutoresizingMaskIntoConstraints = false
        lbTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        lbTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
