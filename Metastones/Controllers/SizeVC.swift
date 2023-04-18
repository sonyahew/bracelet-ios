//
//  SizeVC.swift
//  Metastones
//
//  Created by Sonya Hew on 05/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

@objc protocol PickerDelegate {
    func didSelect(index: Int)
}

class SizeVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var preselectRow: Int?
    var isCancel: Bool = true
    var strTitle: String = ""
    var titles = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = strTitle
        setupPicker()
        if let row = preselectRow {
            pickerView.selectRow(row, inComponent: 0, animated: true)
        }
        
        btnCancel.setTitle(kLb.cancel.localized, for: .normal)
        btnDone.setTitle(kLb.done.localized, for: .normal)
    }
    
    func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        isCancel = true
        self.sheetViewController?.dismiss(animated: true)
    }
    
    @IBAction func doneHandler(_ sender: Any) {
        isCancel = false
        self.sheetViewController?.dismiss(animated: true)
    }
}

extension SizeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = titles[row]
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1137254902, green: 0.1333333333, blue: 0.2117647059, alpha: 1)])
    }
}
