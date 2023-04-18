//
//  GuestDetailsVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 30/06/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit

enum GuestDetailsType {
    case details
    case address
}

class GuestDetailsVC: UIViewController {
    
    let appData = AppData.shared
    
    let profileViewModel = ProfileViewModel()
    let loginViewModel = LoginViewModel()
    let cartViewModel = CartViewModel()
    let popupManager = PopupManager.shared
    var parentVC = DeliveryVC()
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var tfPrefix: UITextField!
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfCountry: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfPostcode: UITextField!
    @IBOutlet weak var tvAddress: UITextView!
    @IBOutlet weak var lbShipping: UILabel!
    @IBOutlet weak var lbBilling: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var btnPrefix: UIButton!
    
    @IBOutlet weak var btnSave: BrownButton!
    
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lbPrefix: UILabel!
    
    @IBOutlet weak var constraintHeightAddr: NSLayoutConstraint!
    
    let cityPicker = UIPickerView()
    let statePicker = UIPickerView()
    let countryPicker = UIPickerView()
    
    var prefixList: [(selection: String, image: String?)] = []
    
    var type: GuestDetailsType = GuestDetailsType.address
    var addrModel: ProfileAddrModel? = ProfileAddrModel()
    
    var addressId: Int? = 0
    var country = 0
    var state = 0
    var city = 0
    var prefix: String?
    
    var countryData = CityStateModule()
    var stateData = CityStateModule()
    var cityData = CityStateModule()
    var prefixData = PrefixModule()
    
    var states: [String] = []
    var cities: [String] = []
    var countries: [String] = []
    
    let titles = [kLb.full_name.localized, kLb.phone_number.localized, kLb.email.localized, kLb.country.localized, kLb.state.localized, kLb.city.localized, kLb.postcode.localized]
    let placeholders = [kLb.enter_your_full_name.localized, kLb.enter_mobile_number.localized, kLb.enter_your_email.localized, kLb.choose_country.localized, kLb.choose_state.localized, kLb.city.localized, kLb.choose_postcode.localized]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getCountry()
        getPrefix()
        setupData()
        getCityState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setupView() {
        var arrTf = [tfFullName, tfPhoneNo, tfEmail]
        if type == .address {
            arrTf.append(contentsOf: [tfCountry, tfState, tfCity, tfPostcode])
        } else {
            lbAddress.isHidden = true
            tvAddress.isHidden = true
            constraintHeightAddr.constant = 0
            
            for (index, view) in stackView.arrangedSubviews.enumerated() {
                if index > 2 && index < stackView.subviews.count-2 {
                    view.isHidden = true
                    stackView.removeArrangedSubview(view)
                }
            }
        }
        
        for (index, tf) in arrTf.enumerated() {
            tf?.delegate = self
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
            if index == 3 || index == 4 {
                tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index], imgRight: #imageLiteral(resourceName: "icon-chev-down.png"))
            }
        }
        
        lbPrefix.text = ""
        tfPrefix.setupTextField(placeholder: "", titleLeft: "", imgRight: #imageLiteral(resourceName: "icon-chev-down.png"))
        
        lbAddress.text = kLb.address.localized.capitalized
        btnSave.setTitle(kLb.save.localized.capitalized, for: .normal)
        tvAddress.delegate = self
        
        tvAddress.contentInset = UIEdgeInsets(top: 32, left: 14, bottom: 16, right: 16)
        tvAddress.applyCornerRadius(cornerRadius: 24)
        tvAddress.layer.borderWidth = 1
        tvAddress.layer.borderColor = UIColor.msBrown.cgColor
        
        lbTitle.text = kLb.guest_details.localized.capitalized
        tvAddress.text = kLb.enter_address.localized
        tvAddress.textColor = .lightGray
    }
    
    func setupData() {
        var addr = ProfileAddrModel()
        
        if let addrModel = addrModel {
            addr = addrModel
        }
        
        addressId = addr.id
        prefix = addr.prefixCallingCode
        country = addr.countryId ?? 0
        state = addr.stateId ?? 0
        tfFullName.text = addr.displayAddrName
        tfEmail.text = addr.displayAddrEmail
        lbPrefix.text = addr.prefixCallingCode
        tfPhoneNo.text = addr.contactNo
        tfCountry.text = addr.countryDesc
        tfState.text = addr.stateDesc
        tfCity.text = addr.cityDesc
        tfPostcode.text = addr.zip
        tvAddress.text = addr.addr1
        
        if lbPrefix.text == "" {
            if let prefix = prefixData.data?.first?.prefixCallingCode {
                lbPrefix.text = prefix
            }
        }
    }
    
    func getCountry() {
        profileViewModel.getCountry { (proceed, data) in
            if proceed {
                if let data = data {
                    self.countryData = data
                    self.countries = data.data?.map({($0.name ?? "")}) ?? []
                }
            }
        }
    }
    
    func getCityState() {
        profileViewModel.getState(countryId: country) { (proceed, data) in
            if proceed {
                if let data = data {
                    self.stateData = data
                    self.states = data.data?.map({($0.name ?? "")}) ?? []
                    self.stackView.subviews[4].isUserInteractionEnabled = self.states.count == 0 ? false : true
                }
            }
        }
    }
    
    func getPrefix() {
        loginViewModel.getPrefix { (proceed, data) in
            if proceed {
                if let data = data {
                    self.prefixData = data
                    self.prefixList = data.data?.map({ (String(format: "%@(%@)", $0.name ?? "", $0.prefixCallingCode ?? ""), $0.mobileImgPath) }) ?? []
                    self.lbPrefix.text = "+\(self.prefixData.data?.first?.prefixCallingCode ?? "")"
                    self.prefix = self.prefixData.data?.first?.prefixCallingCode ?? ""
                }
            }
        }
    }
    
    @IBAction func prefixHandler(_ sender: Any) {
        showSheetedAction(title: kLb.prefix.localized, totalButton: prefixList, fromVC: self) { (selectedValue, selectedIndex) in
            self.lbPrefix.text = "+\(self.prefixData.data?[selectedIndex].prefixCallingCode ?? "")"
            self.prefix = self.prefixData.data?[selectedIndex].prefixCallingCode ?? ""
        }
    }
    
    @IBAction func backHandler(_ sender: Any) {
        if tfPhoneNo.text == "" && tfFullName.text == "" && tfEmail.text == "" && tfCountry.text == "" && tfState.text == "" && tfCity.text == "" && tfPostcode.text == "" && tvAddress.text == "" {
            let vc = getViewControllerFromStackFor(viewController: ProductDetailsVC(), currVC: self)
            navigationController?.popToViewController(vc, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
            parentVC.calculateShipping()
        }
    }
    
    @IBAction func saveHandler(_ sender: Any) {
        var currentAddrModel = ProfileAddrModel()
        
        currentAddrModel.prefixCallingCode = prefix
        currentAddrModel.contactNo = tfPhoneNo.text
        currentAddrModel.addr1 = tvAddress.text
        currentAddrModel.countryId = country
        currentAddrModel.countryDesc = tfCountry.text
        currentAddrModel.stateId = state
        currentAddrModel.stateDesc = tfState.text
        currentAddrModel.cityDesc = tfCity.text
        currentAddrModel.zip = tfPostcode.text
        
        currentAddrModel.displayAddrName = tfFullName.text
        currentAddrModel.address = "\(tvAddress.text ?? "") \(tfCity.text ?? "") \(tfState.text ?? "") \(tfCountry.text ?? "") \(tfPostcode.text ?? "")"
        currentAddrModel.contactDesc = lbPrefix.text != "" && tfPhoneNo.text != "" ? "\(lbPrefix.text ?? "") \(tfPhoneNo.text ?? "")" : ""
        currentAddrModel.displayAddrEmail = tfEmail.text
        
        cartViewModel.saveGuestInfo(prdType: self.type == GuestDetailsType.details ? ProductType.academy.rawValue : ProductType.standard.rawValue, name: currentAddrModel.displayAddrName, mobileNo: currentAddrModel.contactNo, address: currentAddrModel.addr1, country: currentAddrModel.countryId, city: currentAddrModel.cityDesc, state: currentAddrModel.stateId, zip: currentAddrModel.zip, email: currentAddrModel.displayAddrEmail, prefix: currentAddrModel.prefixCallingCode) { (proceed, data) in
            if proceed {
                let deliveryVC = getViewControllerFromStackFor(viewController: DeliveryVC(), currVC: self) as! DeliveryVC
                deliveryVC.guestData = currentAddrModel
                self.navigationController?.popToViewController(deliveryVC, animated: true)
                self.parentVC.calculateShipping()
            } else if data?.err == 97 {
                self.popupManager.showAlert(destVC: self.popupManager.getGeneralPopup(title: "error".localized, desc: data?.msg, strLeftText: "log_in".localized, strRightText: "cancel".localized, style: .warning, isShowSingleBtn: false, isShowNoBtn: false)) { (btnTitle) in
                    if btnTitle == "log_in".localized {
                        let loginVC = getVC(sb: "Main", vc: "LoginPageVC") as! LoginPageVC
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        }
    }
}

extension GuestDetailsVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.textColor = .msBrown
        if textView.text == kLb.enter_address.localized {
            textView.text = ""
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.contentInset = UIEdgeInsets(top: 32, left: 14, bottom: 16, right: 16)
            textView.text = kLb.enter_address.localized
            textView.textColor = .lightGray
        }
    }
}

extension GuestDetailsVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfCountry {
            getPickerSheetedController(title: kLb.choose_country.localized.capitalized, dataArr: countries, forVC: self, selectedRow: country) { (btnTitle, btnIndex) in
                self.profileViewModel.getState(countryId: self.countryData.data?[btnIndex].id ?? 0) { (proceed, data) in
                    if let data = data {
                        self.stateData = data
                        self.states = data.data?.map({$0.name ?? ""}) ?? []
                        if self.states.count == 0 {
                            self.stackView.subviews[4].isUserInteractionEnabled = false
                            self.state = 0
                        } else {
                            self.stackView.subviews[4].isUserInteractionEnabled = true
                        }
                    }
                }
                self.tfState.text = nil
                self.tfCity.text = nil
                self.tfCountry.text = self.countries[btnIndex]
                self.country = self.countryData.data?[btnIndex].id ?? 0
            }
            return false
            
        } else if textField == tfState {
            getPickerSheetedController(title: kLb.choose_state.localized.capitalized, dataArr: states, forVC: self, selectedRow: state) { (btnTitle, btnIndex) in
                self.tfState.text = self.states[btnIndex]
                self.state = self.stateData.data?[btnIndex].id ?? 0
            }
            return false
        }
        return true
    }
}
