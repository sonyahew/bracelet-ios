//
//  SignupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 16/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {
    
    let appData = AppData.shared
    let loginViewModel = LoginViewModel()
    let popup = PopupManager()
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var btnSignup: BrownButton!
    @IBOutlet weak var tvAgreement: UITextView!
    
    @IBOutlet weak var lbAltLogin: UILabel!
    @IBOutlet weak var btnFb: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var svFbGoogle: UIStackView!
    
    var prefixList: [(selection: String, image: String?)] = []
    var countryData = PrefixModule()
    
    let titles = [kLb.mobile.localized, kLb.full_name.localized, kLb.password.localized, kLb.retype.localized, kLb.email.localized, kLb.date_of_birth.localized, kLb.gender.localized, kLb.referral.localized]
    let placeholders = [kLb.enter_mobile_number.localized, kLb.enter_your_full_name.localized, kLb.enter_password.localized, kLb.retype_password.localized, kLb.enter_email_address.localized, kLb.dd_mm_yyyy.localized, kLb.gender.localized, kLb.enter_referral_code.localized]
    
    var prefix = ""
    var fullName = ""
    var mobileNo = ""
    var password = ""
    var retype = ""
    var email = ""
    var dob = ""
    var gender = ""
    var referral = ""
    
    var viewControllerStack: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTextView()
        btnSignup.setTitle(kLb.sign_up.localized.capitalized, for: .normal)

        lbTitle.text = kLb.create_your_metastones_account.localized
        
        //hide fb
        svFbGoogle.subviews[2].alpha = 0
        getPrefix()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
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
    
    @IBAction func signupHandler(_ sender: Any) {
        loginViewModel.signup(prefix: prefix, mobileNo: mobileNo, fullName: fullName, email: email, referralCode: referral, dob: dob, gender: gender, password: password, confirmPassword: retype, showError: true) { (proceed, data) in
            if proceed {
                if let imgStr = data?.data?.popupImage, imgStr != "" {
                    self.appData.data?.signUpSuccessImgStr = imgStr
                }
                
                self.saveMobileInfo()
            }
        }
    }
    
    func saveMobileInfo() {
        self.loginViewModel.saveMobileInfo { (proceed, _) in
            if self.viewControllerStack.count > 0 {
                self.navigationController?.setViewControllers(self.viewControllerStack, animated: true)
            } else {
                self.navigationController?.pushViewController(getVC(sb: "Landing", vc: "MenuVC"), animated: true)
            }
        }
    }
    
    func setupTextView() {
        tvAgreement.delegate = self
        let text = NSMutableAttributedString(string: kLb.by_clicking_sign_up_i_agree_to.localized)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, text.length))
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, text.length))

        let selectablePart = NSMutableAttributedString(string: " \(kLb.privacy_policy.localized)")
        selectablePart.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, selectablePart.length))

        selectablePart.addAttribute(NSAttributedString.Key.link, value: "", range: NSMakeRange(0, selectablePart.length))
        text.append(selectablePart)
        
        tvAgreement.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.msBrown, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        tvAgreement.attributedText = text
        tvAgreement.isEditable = false
        tvAgreement.isSelectable = true
    }
    
    @IBAction func fbHandler(_ sender: Any) {
    }
    
    @IBAction func googleHandler(_ sender: Any) {
    }
}

extension SignupVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webVC = getVC(sb: "Landing", vc: "WebVC") as! WebVC
        webVC.strUrl = appData.appSetting?.returnPolicy?.url ?? ""
        webVC.strHtml = appData.appSetting?.returnPolicy?.htmlContent ?? ""
        webVC.vcTitle = kLb.privacy_policy.localized
        navigationController?.pushViewController(webVC, animated: true)
        return false
    }
}

extension SignupVC: FieldDelegate {
    
    func qrTapped() {
        let qrVC = QRScanVC()
        qrVC.delegate = self
        navigationController?.pushViewController(qrVC, animated: true)
    }
    
    func textFieldDidChange(text: String, tag: Int) {
        switch tag {
        case 0:
            mobileNo = text
        case 1:
            fullName = text
        case 2:
            password = text
        case 3:
            retype = text
        case 4:
            email = text
        case 5:
            dob = text
        case 6:
            gender = text
        case 7:
            referral = text
        default:
            print("error")
        }
    }
    
    func prefixTapped() {
        showSheetedAction(title: kLb.prefix.localized, totalButton: prefixList, fromVC: self) { (selectedValue, selectedIndex) in
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SignupTVC
            cell.ivPrefix.loadWithCache(strUrl: self.prefixList[selectedIndex].image)
            cell.lbPrefix.text = "+\(self.countryData.data?[selectedIndex].prefixCallingCode ?? "")"
            self.prefix = self.countryData.data?[selectedIndex].prefixCallingCode ?? ""
        }
    }
}

extension SignupVC: QRScanVCDelegate {
    func returnQRValue(value: String) {
        referral = value
        let cell = self.tableView.cellForRow(at: IndexPath(row: 7, section: 0)) as! SignupTVC
        cell.tfField.text = value
    }
}

extension SignupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "signupTVC") as! SignupTVC
        cell.selectionStyle = .none
        cell.setupTextField(placeholder: placeholders[indexPath.row], titleLeft: titles[indexPath.row])
        cell.tag = indexPath.row
        cell.delegate = self
        cell.awakeFromNib()
        switch indexPath.row {
        case 0: //prefix
            cell.setupAsPrefix()
            cell.ivPrefix.loadWithCache(strUrl: prefixList.first?.image ?? "")
            cell.lbPrefix.text = "+\(countryData.data?.first?.prefixCallingCode ?? "")"
            prefix = countryData.data?.first?.prefixCallingCode ?? ""
            cell.tfField.keyboardType = .asciiCapableNumberPad
            
        case 2: //password
            cell.setupAsPassword(isPassword: true, withGuide: true)
            
        case 3: //confirm password
            cell.setupAsPassword(isPassword: true, withGuide: false)
            
        case 4: //email
            cell.tfField.keyboardType = .emailAddress
            
        case 5:
            cell.setupAsDatePicker()
            
        case 6:
            cell.setupAsGenderPicker()
            
        case 7 : //referral
            cell.setupAsReferral()
            
        default:
            return cell
        }
        return cell
    }
}

class SignupTVC: UITableViewCell {
    
    @IBOutlet weak var tfField: UITextField!
    @IBOutlet weak var tfPrefix: UITextField!
    @IBOutlet weak var lbPwGuide: UILabel!
    @IBOutlet weak var btnQr: UIButton!
    @IBOutlet weak var btmTfConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTfConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftTfConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnPrefix: UIButton!
    @IBOutlet weak var ivPrefix: UIImageView!
    @IBOutlet weak var lbPrefix: UILabel!
    
    weak var delegate: FieldDelegate?
    
    var selectedGenderIndex = 0
    
    let datePicker = UIDatePicker()
    let picker = UIPickerView()
    
    override func awakeFromNib() {
        tfField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        setupAsPassword(isPassword: false, withGuide: false)
        tfPrefix.isHidden = true
        btnPrefix.isHidden = true
        ivPrefix.isHidden = true
        lbPrefix.isHidden = true
        btnQr.isHidden = true
        btnQr.layer.borderWidth = 1
        btnQr.layer.borderColor = UIColor.msBrown.cgColor
        btnQr.applyCornerRadius(cornerRadius: 24)
        rightTfConstraint.constant = 32
    }
    
    func setupTextField(placeholder: String, titleLeft: String) {
        tfField.setupTextField(placeholder: placeholder, textColor: .msBrown, placeholderColor: UIColor(hex: 0x7C7C7C), titleLeft: titleLeft, cornerRadius: 24)
    }
    
    func setupAsPassword(isPassword: Bool, withGuide: Bool) {
        if withGuide {
            btmTfConstraint.constant = 24
        } else {
            btmTfConstraint.constant = 8
        }
        lbPwGuide.text = kLb.minimum_8_character_with_a_number_and_letter.localized
        lbPwGuide.isHidden = !withGuide
        tfField.isSecureTextEntry = isPassword
    }
    
    func setupAsReferral() {
        rightTfConstraint.constant = 86
        btnQr.isHidden = false
    }
    
    func setupAsPrefix() {
        btnPrefix.isHidden = false
        tfPrefix.isHidden = false
        ivPrefix.isHidden = false
        lbPrefix.isHidden = false
        tfPrefix.setupTextField(placeholder: "", textColor: .msBrown, placeholderColor: UIColor(hex: 0x7C7C7C), imgRight: #imageLiteral(resourceName: "icon-chev-down.png"), cornerRadius: 24)
        leftTfConstraint.constant = 96+32+6
    }
    
    func setupAsDatePicker() {
        datePicker.datePickerMode = .date
        tfField.inputView = datePicker
        setupPicker()
        datePicker.addTarget(self, action: #selector(datePickerHandler(sender:)), for: .valueChanged)
    }
    
    func setupAsGenderPicker() {
        tfField.inputView = picker
        setupPicker()
        picker.delegate = self
    }
    
    private func setupPicker() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: kLb.done.localized, style: .plain, target: self, action: #selector(doneHandler))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: kLb.cancel.localized, style: .plain, target: self, action: #selector(cancelHandler))
                
        tfField.inputAccessoryView = toolbar
        
        toolbar.sizeToFit()
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    @objc private func doneHandler(){
        if tfField.inputView == datePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            tfField.text = dateFormatter.string(from: datePicker.date)
            delegate?.textFieldDidChange(text: tfField.text ?? "", tag: tag)
        }
        tfField.resignFirstResponder()
    }
    
    @objc private func cancelHandler(){
        tfField.resignFirstResponder()
    }
    
    @objc func datePickerHandler(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        tfField.text = dateFormatter.string(from: sender.date)
        delegate?.textFieldDidChange(text: tfField.text ?? "", tag: tag)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(text: textField.text ?? "", tag: tag)
    }
    
    @IBAction func qrHandler(_ sender: Any) {
        delegate?.qrTapped()
    }
    
    @IBAction func prefixTapped(_ sender: Any) {
        delegate?.prefixTapped()
    }
    
}

extension SignupTVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let genderData = genders[row]
        tfField.text = genderData.title
        selectedGenderIndex = row
        
        let gender = genders[row].value
        delegate?.textFieldDidChange(text: gender, tag: tag)
    }
}


