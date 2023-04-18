//
//  ColorBalPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 06/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol ColorBalPopupVCDelegate: class {
    func tapSubmit(sourceVC: ColorBalPopupVC)
}

class ColorBalPopupVC: UIViewController {
    
    let popupManager = PopupManager.shared
    let homeViewModel = HomeViewModel()

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfDOB: DatePickerTF!
    @IBOutlet weak var tfTOB: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var btnSubmit: BrownButton!
    @IBOutlet weak var lbCustomize: UILabel!
    
    weak var delegate: CustomizeTVCDelegate?
    weak var tapDelegate: ColorBalPopupVCDelegate?
    
    var day: String? = ""
    var month: String? = ""
    var year: String? = ""
    var hour: String? = ""
    var gender: String? = ""
    var selectedHour: Int? = 0
    var selectedGender: Int? = 0
    
    var popupTitle: String = ""
    
    let titles = [kLb.date_of_birth.localized, kLb.time_of_birth.localized, kLb.gender.localized]
    let placeholders = [kLb.dd_mm_yyyy.localized, kLb.hour_optional.localized, kLb.select_gender.localized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwContainer.applyCornerRadius(cornerRadius: 24)
        vwContainer.addShadow(withRadius: 12, opacity: 0.12, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 3))
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -100
        let minDate = calendar.date(byAdding: components, to: Date())!

        tfDOB.datePicker.minimumDate = minDate
        tfDOB.datePicker.maximumDate = Date()
        tfDOB.delegate = self
        tfTOB.delegate = self
        tfGender.delegate = self
        
        let tfs = [tfDOB, tfTOB, tfGender]
        for (index, tf) in tfs.enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
            if isSmallScreen {
                tf?.applyCornerRadius(cornerRadius: 21)
            }
        }
        
        lbTitle.text = "\(kLb.do_you_want_to_save_this_date_of_birth.localized)"
        btnSubmit.setTitle(kLb.submit.localized.capitalized, for: .normal)
    }
    
    @IBAction func submitHandler(_ sender: Any) {
        if let day = day, day != "" {
            homeViewModel.calculateBazi(year: year, month: month, day: day, hour: hour, gender: gender) { (proceed, data) in
                if proceed {
                    self.delegate?.didSubmitBazi(data: data?.data, userNameDOB: "")
                    self.tapDelegate?.tapSubmit(sourceVC: self)
                }
            }
            
        } else {
            popupManager.showAlert(destVC: popupManager.getAlertPopup(title: kLb.date_of_birth_is_required.localized, desc: ""))
        }
    }
    
    @IBAction func dismissHandler(_ sender: Any) {
        tapDelegate?.tapSubmit(sourceVC: self)
    }
}

extension ColorBalPopupVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfTOB {
            getPickerSheetedController(title: kLb.time_of_birth.localized, dataArr: hours, forVC: self, selectedRow: selectedHour) { (btnTitle, btnIndex) in
                self.hour = btnTitle
                self.selectedHour = btnIndex
                textField.text = btnTitle
            }
            return false
            
        } else if textField == tfGender {
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
            day = tfDOB.datePicker.date.day
            month = tfDOB.datePicker.date.month
            year = tfDOB.datePicker.date.year
        }
    }
}
