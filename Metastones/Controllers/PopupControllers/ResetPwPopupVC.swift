//
//  ResetPwPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 06/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol ResetPasswordPopupDelegate: class {
    func tapBtnSubmit(sourceVC : ResetPwPopupVC)
}

class ResetPwPopupVC: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfMobileNo: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRetype: UITextField!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var btnSubmit: BrownButton!
    @IBOutlet weak var lbResend: UILabel!
    
    weak var delegate: ResetPasswordPopupDelegate?
    
    var btnTitle: String = ""
    let leftTitles = ["mobile*", "password", "retype"]
    let placeholders = ["013290432", "enter_password", "retype_password"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwContainer.applyCornerRadius(cornerRadius: 10)
        lbTitle.text = "reset_password"
        btnSubmit.setTitle(btnTitle, for: .normal)
        
        for (index, tf) in [tfMobileNo, tfPassword, tfRetype].enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], textColor: UIColor(hex: 0x927A5A), placeholderColor: UIColor(hex: 0xC4BDB4), titleLeft: leftTitles[index])
        }
    }
    
    @IBAction func submitHandler(_ sender: Any) {
        delegate?.tapBtnSubmit(sourceVC: self)
    }
}
