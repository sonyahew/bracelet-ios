//
//  AddAddressVC.swift
//  Metastones
//
//  Created by Sonya Hew on 30/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum EditAddressType: String {
    case shipping = "SHIPPING"
    case billing = "BILLING"
    case both = "BOTH"
    case none = ""
}

enum EditAddress {
    case add
    case edit
}

class AddAddressVC: UIViewController {
    
    let appData = AppData.shared
    let profileViewModel = ProfileViewModel()
    let loginViewModel = LoginViewModel()
    let popup = PopupManager()
    
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
    
    @IBOutlet weak var shippingSwitch: UISwitch!
    @IBOutlet weak var billingSwitch: UISwitch!
    
    @IBOutlet weak var btnSave: BrownButton!
    
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lbPrefix: UILabel!
    
    let cityPicker = UIPickerView()
    let statePicker = UIPickerView()
    let countryPicker = UIPickerView()
    
    var prefixList: [(selection: String, image: String?)] = []
    
    var addrIndex: Int?
    var addrModel: ProfileAddrModel?
    
    var editAddress: EditAddress = .add
    var addressId: Int? = 0
    var addressType : EditAddressType = .none
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
    
    func setupView() {
        for (index, tf) in [tfFullName, tfPhoneNo, tfEmail, tfCountry, tfState, tfCity, tfPostcode].enumerated() {
            tf?.delegate = self
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
            if index == 3 || index == 4 {
                tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index], imgRight: #imageLiteral(resourceName: "icon-chev-down.png"))
            }
        }
        
        tfPrefix.setupTextField(placeholder: "", titleLeft: "", imgRight: #imageLiteral(resourceName: "icon-chev-down.png"))
        
        lbAddress.text = kLb.address.localized.capitalized
        lbBilling.text = kLb.make_default_billing_address.localized
        lbShipping.text = kLb.make_default_shipping_address.localized
        btnSave.setTitle(kLb.save.localized.capitalized, for: .normal)
        tvAddress.delegate = self
        
        tvAddress.contentInset = UIEdgeInsets(top: 32, left: 14, bottom: 16, right: 16)
        tvAddress.applyCornerRadius(cornerRadius: 24)
        tvAddress.layer.borderWidth = 1
        tvAddress.layer.borderColor = UIColor.msBrown.cgColor
        
        //btnSave.addShadow(withRadius: 8, opacity: 1, color: UIColor.msBrown.cgColor, offset: CGSize(width: 0, height: 6))
        
//        tfCountry.inputView = countryPicker
//        tfState.inputView = statePicker
//        tfCity.inputView = cityPicker
        
//        countryPicker.delegate = self
//        statePicker.delegate = self
//        cityPicker.delegate = self
        
        if editAddress == .add {
            lbTitle.text = kLb.add_new_address.localized.capitalized
            tvAddress.text = kLb.enter_address.localized
            tvAddress.textColor = .lightGray
        } else {
            lbTitle.text = kLb.edit_address.localized.capitalized
            tvAddress.textColor = .msBrown
        }
    }
    
    func setupData() {
        if editAddress == .edit {
            
            var addr = ProfileAddrModel()
            
            if let addrModel = addrModel {
                addr = addrModel
            } else {
                if let addrIndex = addrIndex {
                    addr = appData.profile?.addr[addrIndex] ?? ProfileAddrModel()
                }
            }
            
            addressId = addr.id
            prefix = addr.prefixCallingCode
            country = addr.countryId ?? 0
            state = addr.stateId ?? 0
            tfFullName.text = addr.displayAddrName
            tfEmail.text = addr.displayAddrEmail
            lbPrefix.text = addr.prefixCallingCode ?? ""
            tfPhoneNo.text = addr.contactNo
            tfCountry.text = addr.countryDesc
            tfState.text = addr.stateDesc
            tfCity.text = addr.cityDesc
            tfPostcode.text = addr.zip
            tvAddress.text = addr.addr1
            
            if lbPrefix.text?.replacingOccurrences(of: " ", with: "") == "" {
                if let prefix = prefixData.data?.first?.prefixCallingCode {
                    lbPrefix.text = prefix
                }
            }
            
            if addr.defaultBilling == 1 {
                billingSwitch.isOn = true
            } else {
                billingSwitch.isOn = false
            }
            
            if addr.defaultShipping == 1 {
                shippingSwitch.isOn = true
            } else {
                shippingSwitch.isOn = false
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
                    if self.editAddress == .add {
                        self.lbPrefix.text = "+\(self.prefixData.data?.first?.prefixCallingCode ?? "")"
                        self.prefix = self.prefixData.data?.first?.prefixCallingCode ?? ""
                    } else {
                        if self.lbPrefix.text == "" {
                            self.lbPrefix.text = "+\(self.prefixData.data?.first?.prefixCallingCode ?? "")"
                            self.prefix = self.prefixData.data?.first?.prefixCallingCode ?? ""
                        }
                    }
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
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shippingSwitch(_ sender: Any) {
    }
    
    @IBAction func billingSwitch(_ sender: Any) {
    }
    
    @IBAction func saveHandler(_ sender: Any) {
        if shippingSwitch.isOn && billingSwitch.isOn {
            addressType = .both
        } else if shippingSwitch.isOn {
            addressType = .shipping
        } else if billingSwitch.isOn {
            addressType = .billing
        } else {
            addressType = .none
        }
        
        if editAddress == .edit {
            profileViewModel.updateAddress(category: "UPDATE",
                                           addressId: addressId,
                                           addrType: addressType.rawValue,
                                           name: tfFullName.text ?? "",
                                           mobileNo: tfPhoneNo.text ?? "",
                                           address: tvAddress.text ?? "",
                                           country: country,
                                           city: tfCity.text ?? "",
                                           state: state,
                                           zip: tfPostcode.text ?? "",
                                           email: tfEmail.text ?? "",
                                           prefix: prefix )
            { (proceed, data) in
                if proceed {
                    self.popViewController(msg: data?.msg)
                }
            }
        } else {
            profileViewModel.updateAddress(category: "ADD",
                                           addrType: addressType.rawValue,
                                           name: tfFullName.text ?? "",
                                           mobileNo: tfPhoneNo.text ?? "",
                                           address: tvAddress.text ?? "",
                                           country: country,
                                           city: tfCity.text ?? "",
                                           state: state,
                                           zip: tfPostcode.text ?? "",
                                           email: tfEmail.text ?? "",
                                           prefix: prefix)
            { (proceed, data) in
                if proceed {
                    self.popViewController(msg: data?.msg)
                }
            }
        }
    }
    
    func popViewController(msg: String?) {
        self.popup.showAlert(destVC: self.popup.getSuccessPopup(desc: msg)) { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension AddAddressVC: UITextViewDelegate {
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

extension AddAddressVC: UITextFieldDelegate {
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

//extension AddAddressVC: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == countryPicker {
//            return countries.count
//        } else if pickerView == statePicker {
//            return states.count
//        } else {
//            return cities.count
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == countryPicker {
//            return countries[row]
//        } else if pickerView == statePicker {
//            return states[row]
//        } else {
//            return cities[row]
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView == countryPicker {
//            self.profileViewModel.getState(countryId: countryData.data?[row].id ?? 0) { (proceed, data) in
//                if let data = data {
//                    self.stateData = data
//                    self.states = data.data?.map({$0.name ?? ""}) ?? []
//                    if self.states.count == 0 {
//                        self.stackView.subviews[4].isUserInteractionEnabled = false
//                        self.state = 0
//                    } else {
//                        self.stackView.subviews[4].isUserInteractionEnabled = true
//                    }
//                }
//            }
//            tfState.text = nil
//            tfCity.text = nil
//            tfCountry.text = countries[row]
//            country = countryData.data?[row].id ?? 0
//
//        } else if pickerView == statePicker {
////            self.profileViewModel.getCity(stateId: stateData.data?[row].id ?? 0) { (proceed, data) in
////                if let data = data {
////                    self.cityData = data
////                    self.cities = data.data?.map({($0.name ?? "")}) ?? []
////                }
////            }
//            //tfCity.text = nil
//            tfState.text = states[row]
//            state = stateData.data?[row].id ?? 0
//
//        } else {
//            //tfCity.text = cities[row]
//            city = cityData.data?[row].id ?? 0
//        }
//    }
//}
