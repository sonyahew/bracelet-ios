//
//  WithdrawalVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 30/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class WithdrawalVC: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbWalletType: UILabel!
    @IBOutlet weak var lbWalletBalance: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lbTitle1: UILabel!
    @IBOutlet weak var tfBankName: UITextField!
    @IBOutlet weak var tfBankAccNo: UITextField!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var tfIdNo: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPrefix: UITextField!
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var btnPrefix: UIButton!
    
    @IBOutlet weak var ivFlag: UIImageView!
    @IBOutlet weak var lbPrefix: UILabel!
    
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var lbTitle2: UILabel!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var lbMinimum: UILabel!
    @IBOutlet weak var lbMaximum: UILabel!
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var lbBalanceValue: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountValue: UILabel!
    @IBOutlet weak var lbAdminFee: UILabel!
    @IBOutlet weak var lbAdminFeeValue: UILabel!
    @IBOutlet weak var lbTotalAmount: UILabel!
    @IBOutlet weak var lbTotalAmountValue: UILabel!
    @IBOutlet weak var lbNewBalance: UILabel!
    @IBOutlet weak var lbNewBalanceValue: UILabel!
    @IBOutlet weak var lbPolicy: UILabel!
    @IBOutlet weak var btnPolicy: UIButton!
    @IBOutlet weak var btnWithdrawal: BrownButton!
    
    let popupManager = PopupManager.shared
    let loginViewModel = LoginViewModel()
    let profileViewModel = ProfileViewModel()
    let titles = [kLb.bank_name.localized, kLb.bank_account_no.localized, kLb.full_name_as_in_ic.localized, kLb.identification_card_no.localized, kLb.email.localized, kLb.mobile.localized, "MYR"]
    let placeholders = [kLb.enter_bank_name.localized, kLb.enter_bank_account_no.localized, kLb.enter_full_name.localized, kLb.enter_ic.localized, kLb.enter_email_address.localized, kLb.enter_mobile_number.localized, ""]
    
    var prefixList: [(selection: String, image: String?)] = []
    var prefix: String?
    var selectedBankId: Int?
    var prefixData = PrefixModule()
    var withdrawalData: WithdrawalModel?
    var arrBank: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupData()
    }
    
    func setupView() {
        lbTitle.text = kLb.withdrawal.localized
        
        for (index, tf) in [tfBankName, tfBankAccNo, tfFullName, tfIdNo, tfEmail, tfPhoneNo, tfAmount].enumerated() {
            if index == 0 {
                tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index], imgRight: #imageLiteral(resourceName: "icon-chev-down.png"))
            } else {
                tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index], titleLeftCapitalized: tf != tfAmount)
            }
        }
        
        lbTitle1.text = kLb.bank_details.localized
        lbTitle2.text = kLb.withdraw_details.localized
        
        lbPrefix.text = ""
        tfPrefix.setupTextField(placeholder: "", titleLeft: "", imgRight: #imageLiteral(resourceName: "icon-chev-down.png"))
        
        tfBankName.delegate = self
        tfAmount.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tfAmount.text = "0.00"
        
        lbBalance.text = kLb.balance.localized
        lbAmount.text = kLb.amount.localized
        lbAdminFee.text = kLb.admin_fee.localized
        lbTotalAmount.text = kLb.total_amount.localized
        lbNewBalance.text = kLb.new_balance.localized
        
        let text = NSMutableAttributedString(string: kLb.by_clicking_withdraw_i_agree_to.localized)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, text.length))
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, text.length))
        let selectablePart = NSMutableAttributedString(string: " \(kLb.withdrawal_policy.localized)")
        selectablePart.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, selectablePart.length))
        selectablePart.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.msBrown, range: NSMakeRange(0, selectablePart.length))
        text.append(selectablePart)
        lbPolicy.attributedText = text
        
        btnWithdrawal.setTitle(kLb.withdrawal.localized, for: .normal)
        enableWithdrawal(enable: false)
    }
    
    func getPrefix() {
        loginViewModel.getPrefix { (proceed, data) in
            if proceed {
                if let data = data {
                    self.prefixData = data
                    self.prefixList = data.data?.map({ (String(format: "%@(%@)", $0.name ?? "", $0.prefixCallingCode ?? ""), $0.mobileImgPath) }) ?? []
                    
                    if self.prefix == "" {
                        self.lbPrefix.text = "+\(self.prefixData.data?.first?.prefixCallingCode ?? "")"
                        self.prefix = self.prefixData.data?.first?.prefixCallingCode ?? ""
                    }
                }
            }
        }
    }
    
    func setupData() {
        profileViewModel.getWithdrawalPage { (proceed, data) in
            if proceed {
                self.withdrawalData = data
                self.arrBank = data?.data?.bankList.filter({ $0?.name != "" }).map({ $0?.name ?? "" }) ?? []
                self.lbWalletType.text = data?.data?.ewalletTypeName
                self.lbWalletBalance.text = "\(data?.data?.currencyCode ?? "")\(data?.data?.balance?.toDisplayCurrency() ?? "")"
                self.lbBalanceValue.text = self.lbWalletBalance.text
                self.lbNewBalanceValue.text = self.lbWalletBalance.text
                self.lbAdminFeeValue.text = "\(data?.data?.currencyCode ?? "")\(data?.data?.processingFee?.toDisplayCurrency() ?? "")"
                self.lbMinimum.text = "\(kLb.minimum.localized): \(data?.data?.currencyCode ?? "")\(data?.data?.minimumAmount?.toDisplayCurrency() ?? "")"
                self.lbMaximum.text = "\(kLb.maximum.localized): \(data?.data?.currencyCode ?? "")\(data?.data?.maximumAmount?.toDisplayCurrency() ?? "")"
                
                self.selectedBankId = data?.data?.memberBank?.bankTypeId
                let selectedBank = data?.data?.bankList.filter({ $0?.id == self.selectedBankId }).first
                self.tfBankName.text = selectedBank??.name
                self.tfBankAccNo.maxLength = Int(selectedBank??.accNoLength ?? "") ?? Int.max
                self.tfBankAccNo.text = data?.data?.memberBank?.bankAccNo
                self.tfFullName.text = data?.data?.memberBank?.bankAccName
                self.tfIdNo.text = data?.data?.memberBank?.bankAccNric
                self.tfEmail.text = data?.data?.memberBank?.bankAccEmail
                self.lbPrefix.text = "+\(data?.data?.memberBank?.bankAccMobilePrefixNo ?? "")"
                self.prefix = data?.data?.memberBank?.bankAccMobilePrefixNo ?? ""
                self.tfPhoneNo.text = data?.data?.memberBank?.bankAccMobileNo
                
                self.getPrefix()
            }
        }
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            let doubleAmt = Double(amountString.currencyWithoutGrouping()) ?? 0.0
            let doubleAvailableMax = Double(withdrawalData?.data?.maximumAmount ?? "") ?? 0.0
            let doubleAvailableBalance = Double(withdrawalData?.data?.balance ?? "") ?? 0.0
            let amtToCheck = doubleAvailableMax > doubleAvailableBalance ? doubleAvailableBalance : doubleAvailableMax
            
            if doubleAmt > amtToCheck {
                textField.resignFirstResponder()
                textField.text = "\(amtToCheck)".toDisplayCurrency()
                
            } else {
                textField.text = amountString
            }
            
            let doubleTfValue = Double(textField.text ?? "") ?? 0.0
            let doubleAdminFee = Double(withdrawalData?.data?.processingFee ?? "") ?? 0.0
            lbAmountValue.text = "\(withdrawalData?.data?.currencyCode ?? "")\(doubleTfValue.toStrDisplayCurr)"
            lbTotalAmountValue.text = "\(withdrawalData?.data?.currencyCode ?? "")\((doubleTfValue-doubleAdminFee).positiveOnly.toStrDisplayCurr)"
            lbNewBalanceValue.text = "\(withdrawalData?.data?.currencyCode ?? "")\((doubleAvailableBalance-doubleTfValue).toStrDisplayCurr)"
            
            let doubleAvailableMin = Double(withdrawalData?.data?.minimumAmount ?? "") ?? 0.0
            enableWithdrawal(enable: doubleTfValue >= doubleAvailableMin)
        }
    }
    
    func enableWithdrawal(enable: Bool) {
        btnWithdrawal.alpha = enable ? 1.0 : 0.5
        btnWithdrawal.isUserInteractionEnabled = enable
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func policyHandler(_ sender: Any) {
        let webVC = getVC(sb: "Landing", vc: "WebVC") as! WebVC
        webVC.strHtml = withdrawalData?.data?.withdrawalPolicy ?? ""
        webVC.vcTitle = kLb.withdrawal_policy.localized
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @IBAction func prefixHandler(_ sender: Any) {
        showSheetedAction(title: kLb.prefix.localized, totalButton: prefixList, fromVC: self) { (selectedValue, selectedIndex) in
            self.lbPrefix.text = "+\(self.prefixData.data?[selectedIndex].prefixCallingCode ?? "")"
            self.prefix = self.prefixData.data?[selectedIndex].prefixCallingCode ?? ""
        }
    }
    
    @IBAction func withdrawalHandler(_ sender: Any) {
        if validatedInput() {
            loginViewModel.sendOTP(prefix: prefix, mobileNo: tfPhoneNo.text) { (proceed, data) in
                if proceed {
                    self.popupManager.showAlert(destVC: self.popupManager.getOTPPopup(validSec: data?.data?.validTime ?? 60, fullName: self.tfFullName.text, prefix: self.prefix, mobileNo: self.tfPhoneNo.text, email: self.tfEmail.text, nric: self.tfIdNo.text, bankTypeId: "\(self.selectedBankId ?? 0)", bankAccNo: self.tfBankAccNo.text, withdrawAmt: self.tfAmount.text?.currencyWithoutGrouping())) { (message) in
                        
                        if message != "" {
                            self.popupManager.showAlert(destVC: self.popupManager.getSuccessPopup(desc: message)) { (btnTitle) in
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            popupManager.showAlert(destVC: popupManager.getAlertPopup(desc: kLb.field_is_required.localized))
        }
    }
    
    func validatedInput() -> Bool {
        return tfBankName.text != "" && tfBankAccNo.text != "" && tfFullName.text != "" && tfIdNo.text != "" && tfEmail.text != "" && lbPrefix.text != "" && tfPhoneNo.text != ""
    }
}

extension WithdrawalVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfBankName {
            showActionSheet(title: "", message: kLb.bank_name.localized, totalButton: arrBank, fromVC: self, sourceView: tfBankName) { (alertController, btnIndex, btnTitle) in
                textField.text = btnTitle
                self.tfBankAccNo.maxLength = Int(self.withdrawalData?.data?.bankList[btnIndex]?.accNoLength ?? "") ?? Int.max
                self.selectedBankId = self.withdrawalData?.data?.bankList[btnIndex]?.id
                self.tfBankAccNo.text = ""
                self.tfFullName.text = ""
                self.tfIdNo.text = ""
                self.tfEmail.text = ""
                self.tfPhoneNo.text = ""
            }
            return false
        }
        
        return true
    }
}
