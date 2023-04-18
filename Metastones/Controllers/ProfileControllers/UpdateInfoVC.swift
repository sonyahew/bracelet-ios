//
//  UpdateInfoVC.swift
//  Metastones
//
//  Created by Sonya Hew on 30/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class UpdateInfoVC: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfFullname: UITextField!
    @IBOutlet weak var tfDOB: DatePickerTF!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    
    @IBOutlet weak var btnSave: BrownButton!
    
    let appData = AppData.shared
    let popupManager = PopupManager()
    let profileViewModel = ProfileViewModel()
    let titles = [kLb.full_name.localized, kLb.date_of_birth.localized, kLb.email.localized, kLb.gender.localized]
    let placeholders = [kLb.enter_your_full_name.localized, kLb.dd_mm_yyyy.localized, kLb.enter_your_email.localized, kLb.select_gender.localized]
    var values : [String] = []
    
    var dob: String? = ""
    var gender: String? = ""
    var selectedGender: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        lbTitle.text = kLb.update_personal_info.localized.capitalized
        btnSave.setTitle(kLb.save.localized.capitalized, for: .normal)
    }
    
    func setupView() {
        values.append(appData.profile?.profile?.fullName ?? "")
        values.append(appData.profile?.profile?.birthDate ?? "")
        values.append(appData.profile?.profile?.email ?? "")
        values.append(genders.filter({ $0.value == appData.profile?.profile?.gender }).first?.title ?? "")
        
        for (index, tf) in [tfFullname, tfDOB, tfEmail, tfGender].enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
            tf?.text = values.indices.contains(index) ? values[index] : ""
            if tf == tfDOB {
                dob = tf?.text
            }
        }
        
        tfDOB.datePicker.setDate(dob?.toDate(fromFormat: tfDOB.dateFormat) ?? Date(), animated: true)
        tfDOB.datePicker.maximumDate = Date()
        tfDOB.delegate = self
        selectedGender = genders.indices.filter({ genders[$0].value == appData.profile?.profile?.gender }).first
        tfGender.delegate = self
        
        //btnSave.addShadow(withRadius: 8, opacity: 1, color: UIColor.msBrown.cgColor, offset: CGSize(width: 0, height: 6))
        btnSave.setTitle(kLb.save.localized.capitalized, for: .normal)
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveHandler(_ sender: Any) {
        profileViewModel.updateProfile(fullName: tfFullname.text, dob: dob, email: tfEmail.text, gender: gender) { (proceed, data) in
            if proceed {
                self.popupManager.showAlert(destVC: self.popupManager.getSuccessPopup(title: data?.msg, desc: "")) { (btnTitle) in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}

extension UpdateInfoVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfGender {
            getPickerSheetedController(title: kLb.gender.localized, dataArr: genders.map({ $0.title }), forVC: self, selectedRow: selectedGender) { (btnTitle, btnIndex) in
                self.gender = genders.filter({ $0.title == btnTitle }).map({ $0.value }).first
                self.selectedGender = btnIndex
                textField.text = btnTitle
            }
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfDOB {
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dob = dateFormatter.string(from: tfDOB.datePicker.date)
        }
    }
}
