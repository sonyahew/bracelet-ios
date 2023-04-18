//
//  SaveDOBPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 06/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol SaveDOBPopupVCDelegate: class {
    func tapBtnLeft(sourceVC : SaveDOBPopupVC)
    func tapBtnRight(sourceVC : SaveDOBPopupVC)
}

class SaveDOBPopupVC: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfMobileNo: UITextField!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    weak var delegate: SaveDOBPopupVCDelegate?
    
    let profileViewModel = ProfileViewModel()
    let popupManager = PopupManager.shared
    
    var popupTitle: String = ""
    var leftBtnTitle: String = ""
    var rightBtnTitle: String = ""
    
    var year: String? = ""
    var month: String? = ""
    var day: String? = ""
    var hour: String?
    var gender: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for btn in [btnLeft, btnRight, tfMobileNo] {
            btn?.applyCornerRadius(cornerRadius: btnLeft.bounds.height/2)
        }
        
        vwContainer.applyCornerRadius(cornerRadius: 10)

        lbTitle.text = popupTitle
        tfMobileNo.layer.borderWidth = 1
        tfMobileNo.layer.borderColor = UIColor.init(hex: 0xC7C7C7).cgColor
        tfMobileNo.setupTextField(placeholder: "", titleLeft: kLb.nickname.localized)
        btnLeft.setTitle(leftBtnTitle, for: .normal)
        btnRight.setTitle(rightBtnTitle, for: .normal)
    }
    
    @IBAction func leftHandler(_ sender: Any) {
        profileViewModel.saveBazi(year: year, month: month, day: day, hour: hour, gender: gender, name: tfMobileNo.text) { (proceed, data) in
            if proceed {
                self.delegate?.tapBtnLeft(sourceVC: self)
            }
        }
    }
    
    @IBAction func rightHandler(_ sender: Any) {
        delegate?.tapBtnRight(sourceVC: self)
    }
}
