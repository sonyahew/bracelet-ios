//
//  VerifyPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 06/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol VerifyPopupDelegate: class {
    func tapDismiss(sourceVC: VerifyPopupVC, message: String)
}

class VerifyPopupVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMobileNo: UILabel!
    @IBOutlet weak var tfCode: UITextField!
    @IBOutlet weak var btnCancel: ReversedBrownButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lbResendOTP: UILabel!
    @IBOutlet weak var btnResendOTP: UIButton!
    
    weak var delegate: VerifyPopupDelegate?
    
    let profileViewModel = ProfileViewModel()
    
    var timer = Timer()
    var validSec : Int = 0 {
        didSet {
            if validSec > 0 {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setResendSMSBtn), userInfo: nil, repeats: true)
            }
        }
    }
    
    var fullName: String?
    var prefix: String?
    var mobileNo: String?
    var email: String?
    var nric: String?
    var bankTypeId: String?
    var bankAccNo: String?
    var withdrawAmt: String?
    
    var maskedMobileNo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.setTitle(kLb.cancel.localized, for: .normal)
        btnSubmit.setTitle(kLb.submit.localized, for: .normal)
        btnSubmit.applyCornerRadius(cornerRadius: btnSubmit.frame.size.height/2)
        lbTitle.text = kLb.we_ve_sent_a_verification_code_to_your_mobile.localized
        lbMobileNo.text = maskedMobileNo
        tfCode.keyboardType = .asciiCapableNumberPad
        tfCode.layer.borderWidth = 1
        tfCode.layer.borderColor = UIColor.lightGray.cgColor
        let radiusHeight = tfCode.frame.size.height/2
        tfCode.applyCornerRadius(cornerRadius: radiusHeight)
        tfCode.setLeftPaddingPoints(radiusHeight)
        tfCode.setRightPaddingPoints(radiusHeight)
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        delegate?.tapDismiss(sourceVC: self, message: "")
    }
    
    @IBAction func submitHandler(_ sender: Any) {
        profileViewModel.saveWithdrawalRequest(fullName: fullName, prefixNo: prefix, mobileNo: mobileNo, email: email, nric: nric, bankTypeId: bankTypeId, bankAccNo: bankAccNo, withdrawAmount: withdrawAmt, otp: tfCode.text) { (proceed, data) in
            if proceed {
                self.delegate?.tapDismiss(sourceVC: self, message: data?.msg ?? "")
            }
        }
    }
    
    @IBAction func resentOTPHandler(_ sender: Any) {
        if mobileNo != "", validSec <= 0 {
            profileViewModel.sendOTP(prefix: prefix, mobileNo: mobileNo) { (proceed, data) in
                if proceed {
                    self.validSec = data?.data?.validTime ?? 60
                }
            }
        }
    }
    
    @objc
    func setResendSMSBtn() {
        timer.invalidate()
        validSec -= 1
        
        if validSec == 0 {
            btnResendOTP.isUserInteractionEnabled = true
            lbResendOTP.text = "\(kLb.resend_otp.localized)"
        } else {
            btnResendOTP.isUserInteractionEnabled = false
            lbResendOTP.text = "\(kLb.resend_otp_in.localized) (\(validSec)s)"
        }
    }
}
