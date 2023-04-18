//
//  LoginVC.swift
//  Metastones
//
//  Created by Sonya Hew on 16/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

@objc protocol FieldDelegate {
    func textFieldDidChange(text: String, tag: Int)
    func prefixTapped()
    func qrTapped()
}

class LoginVC: UIViewController {
    
    let appData = AppData.shared
    let loginViewModel = LoginViewModel()
    let popup = PopupManager()
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var svFbGoogle: UIStackView!
    
    @IBOutlet weak var btnLogin: BrownButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    
    @IBOutlet weak var lbAltLogin: UILabel!
    @IBOutlet weak var btnFb: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    
    let titles = [kLb.mobile.localized, kLb.password.localized]
    let placeholders = [kLb.enter_mobile_number.localized, kLb.enter_password.localized]
    
    var prefixList: [(selection: String, image: String?)] = []
    var countryData = PrefixModule()
    
    var mobileNo = ""
    var password = ""
    var prefix = ""
    
    var viewControllerStack: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        btnPrivacy.titleLabel?.textAlignment = .center
        btnPrivacy.setTitle(kLb.forgot_password.localized, for: .normal)
        lbTitle.text = kLb.welcome_to_metastones_please_login.localized
        btnLogin.setTitle(kLb.log_in.localized.capitalized, for: .normal)
        
        //hide fb
        svFbGoogle.subviews[2].alpha = 0
        getPrefix()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
    }
    
    func getPrefix() {
        loginViewModel.getPrefix { (proceed, data) in
            if proceed {
                if let data = data {
                    self.countryData = data
                    self.prefixList = data.data?.map({ (String(format: "%@(%@)", $0.name ?? "", $0.prefixCallingCode ?? ""), $0.mobileImgPath) }) ?? []
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func forgotPasswordHandler(_ sender: Any) {
        popup.showAlert(destVC: popup.getForgotPassPopup())
    }
    
    @IBAction func loginHandler(_ sender: Any) {
        loginViewModel.login(prefix: prefix, mobile: mobileNo, password: password, showError: true) { (proceed, data) in
            if proceed {
                if let imgStr = data?.data?.popupImage, imgStr != "" {
                    self.appData.data?.signUpSuccessImgStr = imgStr
                }
                
                self.loginViewModel.saveMobileInfo { (proceed, _) in
                    if self.viewControllerStack.count > 0 {
                        if let vc = self.viewControllerStack.last, vc.isKind(of: GeneralPopupVC.self) {
                            self.viewControllerStack.removeLast()
                        }
                        if let vc = self.viewControllerStack.last, vc.isKind(of: GuestDetailsVC.self) {
                            self.viewControllerStack.removeLast()
                        }
                        self.navigationController?.setViewControllers(self.viewControllerStack, animated: true)
                        if let vc = self.viewControllerStack.last, vc.isKind(of: MyCartVC.self) {
                            (vc as! MyCartVC).refreshData()
                        }
                        
                    } else {
                        self.navigationController?.pushViewController(getVC(sb: "Landing", vc: "MenuVC"), animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func fbHandler(_ sender: Any) {
    }
    
    @IBAction func googleHandler(_ sender: Any) {
    }
}

extension LoginVC: FieldDelegate {
    
    func qrTapped() {
        //
    }
    
    func prefixTapped() {
        showSheetedAction(title: kLb.prefix.localized, totalButton: prefixList, fromVC: self) { (selectedValue, selectedIndex) in
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LoginTVC
            cell.ivFlag.loadWithCache(strUrl: self.prefixList[selectedIndex].image)
            cell.lbPrefix.text = "+\(self.countryData.data?[selectedIndex].prefixCallingCode ?? "")"
            self.prefix = self.countryData.data?[selectedIndex].prefixCallingCode ?? ""
        }
    }
    
    func textFieldDidChange(text: String, tag: Int) {
        if tag == 0 {
            mobileNo = text
        } else {
            password = text
        }
    }
}

extension LoginVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loginTVC") as! LoginTVC
        cell.selectionStyle = .none
        cell.setupTextField(placeholder: placeholders[indexPath.row], titleLeft: titles[indexPath.row])
        cell.tag = indexPath.row
        cell.delegate = self
        cell.awakeFromNib()

        if indexPath.row == 0 {
            cell.setupAsPrefix()
            cell.ivFlag.loadWithCache(strUrl: prefixList.first?.image ?? "")
            cell.lbPrefix.text = "+\(countryData.data?.first?.prefixCallingCode ?? "")"
            prefix = countryData.data?.first?.prefixCallingCode ?? ""
            cell.tfField.keyboardType = .asciiCapableNumberPad
        } else {
            cell.setupAsPassword()
        }
        
        return cell
    }
}

class LoginTVC: UITableViewCell {
    
    @IBOutlet weak var tfField: UITextField!
    @IBOutlet weak var btmTfConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tfPrefix: UITextField!
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lbPrefix: UILabel!
    @IBOutlet weak var btnPrefix: UIButton!
    
    weak var delegate: FieldDelegate?
    
    override func awakeFromNib() {
        tfField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnPrefix.isHidden = true
        tfPrefix.isHidden = true
        ivFlag.isHidden = true
        lbPrefix.isHidden = true
    }
    
    func setupTextField(placeholder: String, titleLeft: String) {
        tfField.setupTextField(placeholder: placeholder, textColor: .msBrown, placeholderColor: UIColor(hex: 0x7C7C7C), titleLeft: titleLeft, cornerRadius: 24)
    }
    
    func setupAsPrefix() {
        btnPrefix.isHidden = false
        tfPrefix.isHidden = false
        ivFlag.isHidden = false
        lbPrefix.isHidden = false
        tfPrefix.setupTextField(placeholder: "", textColor: .msBrown, placeholderColor: UIColor(hex: 0x7C7C7C), imgRight: #imageLiteral(resourceName: "icon-chev-down.png"), cornerRadius: 24)
        leftConstraint.constant = 96+32+6
    }
    
    func setupAsPassword() {
        tfField.isSecureTextEntry = true
    }
    
    @IBAction func prefixHandler(_ sender: Any) {
        delegate?.prefixTapped()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(text: textField.text ?? "", tag: tag)
    }
}
