//
//  CreateAccPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 07/07/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit

protocol CreateAccPopupVCDelegate: class {
    func tapBtnLeft(sourceVC : CreateAccPopupVC)
    func tapBtnRight(sourceVC : CreateAccPopupVC)
}

class CreateAccPopupVC: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRetype: UITextField!
    
    weak var delegate: CreateAccPopupVCDelegate?
    
    let profileViewModel = ProfileViewModel()
    let popupManager = PopupManager.shared
    
    var popupTitle: String = kLb.create_a_password_for_metastones_login.localized
    var popupDesc: String = kLb.create_a_login_password.localized + "\n\n" + kLb.you_will_only_be_able_to_view_your_order_once_verified.localized
    var leftBtnTitle: String = kLb.submit.localized
    var rightBtnTitle: String = kLb.no_thanks.localized

    var mobile: String = ""
    var email: String = ""
    var checkoutId: String = ""
    var orderDetailsVC = OrderDetailsVC()
    var isAcademy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for btn in [btnLeft, btnRight, tfMobile, tfEmail, tfPassword, tfRetype] {
            btn?.applyCornerRadius(cornerRadius: btnLeft.bounds.height/2)
        }
        
        vwContainer.applyCornerRadius(cornerRadius: 10)

        lbTitle.text = popupTitle
        lbDesc.text = popupDesc
        tfMobile.layer.borderWidth = 1
        tfMobile.layer.borderColor = UIColor.init(hex: 0xC7C7C7).cgColor
        tfMobile.setupTextField(placeholder: mobile, titleLeft: kLb.mobile.localized)
        tfEmail.setupTextField(placeholder: email, titleLeft: kLb.email.localized)
        tfPassword.setupTextField(placeholder: "", titleLeft: kLb.password.localized)
        tfRetype.setupTextField(placeholder: "", titleLeft: kLb.retype.localized)
        
        tfMobile.text = mobile
        tfEmail.text = email
        btnLeft.setTitle(leftBtnTitle, for: .normal)
        btnRight.setTitle(rightBtnTitle, for: .normal)
    }
    
    @IBAction func leftHandler(_ sender: Any) {
        delegate?.tapBtnLeft(sourceVC: self)
    }
    
    @IBAction func rightHandler(_ sender: Any) {
        delegate?.tapBtnRight(sourceVC: self)
    }
}
