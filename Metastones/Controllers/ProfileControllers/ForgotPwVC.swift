//
//  ForgotPwVC.swift
//  Metastones
//
//  Created by Sonya Hew on 30/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ForgotPwVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRetype: UITextField!
    @IBOutlet weak var lbPwGuide: UILabel!
    @IBOutlet weak var lbResend: UILabel!
    
    @IBOutlet weak var btnSubmit: BrownButton!
    
    let titles = [kLb.mobile.localized, kLb.password.localized, kLb.retype.localized]
    let placeholders = ["Eg: 0123456789", kLb.enter_password.localized, kLb.retype_password.localized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        lbTitle.text = kLb.forgot_password.localized.capitalized
    }
    
    func setupView() {
        for (index, tf) in [tfMobile, tfPassword, tfRetype].enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
        }
        
        //btnSubmit.addShadow(withRadius: 8, opacity: 1, color: UIColor.msBrown.cgColor, offset: CGSize(width: 0, height: 6))
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitHandler(_ sender: Any) {
    }
}
