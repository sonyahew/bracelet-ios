//
//  ForgotPassPopupVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol ForgotPassPopupVCDelegate: class {
    func tapBtnLeft(sourceVC : ForgotPassPopupVC)
    func tapBtnRight(sourceVC : ForgotPassPopupVC)
}

class ForgotPassPopupVC: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    weak var delegate: ForgotPassPopupVCDelegate?
    
    var popupTitle: String = ""
    var leftBtnTitle: String = ""
    var rightBtnTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for btn in [btnLeft, btnRight, tfEmail] {
            btn?.applyCornerRadius(cornerRadius: btnLeft.bounds.height/2)
        }
        
        vwContainer.applyCornerRadius(cornerRadius: 10)
        
        tfEmail?.setupTextField(placeholder: "", textColor: UIColor(hex: 0x927A5A), placeholderColor: UIColor(hex: 0xC4BDB4), titleLeft: kLb.email.localized)
        tfEmail.keyboardType = .emailAddress
        
        lbTitle.text = popupTitle
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
