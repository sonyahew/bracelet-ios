//
//  TextFieldExtension.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setupTextField(placeholder: String, textColor: UIColor? = nil, placeholderColor: UIColor? = nil, titleLeft: String? = nil, titleLeftCapitalized: Bool? = true, imgLeft: UIImage? = nil, imgRight: UIImage? = nil, cornerRadius: CGFloat? = nil) {
        
        setRightPaddingPoints(16)
        
        if let titleLeft = titleLeft {
            let lbLeft = UILabel(frame: CGRect(x: 18, y: 5, width: 100, height: 20))
            lbLeft.font = .systemFont(ofSize: 10, weight: .bold)
            lbLeft.text = titleLeftCapitalized ?? true ? titleLeft.capitalized : titleLeft
            lbLeft.textColor = .msDarkBrown
            let vwLeft: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
            vwLeft.addSubview(lbLeft)
            self.leftView = vwLeft
            self.leftViewMode = .always
            self.textAlignment = .right
        }
        
        if let imgLeft = imgLeft {
            let ivLeft = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
            ivLeft.image = imgLeft
            ivLeft.contentMode = .scaleAspectFit
            let vwImage: UIView = UIView(frame: CGRect(x: 20, y: 0, width: 30, height: 30))
            vwImage.addSubview(ivLeft)
            self.leftView = vwImage
            self.leftViewMode = .always
        }
        
        if let imgRight = imgRight {
            let ivRight = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 32))
            ivRight.image = imgRight
            ivRight.contentMode = .center
            let vwImage: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 32))
            vwImage.addSubview(ivRight)
            self.rightView = vwImage
            self.rightViewMode = .always
        }
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor ?? UIColor.init(hex: 0xAAAAAA)])
        self.textColor = textColor ?? .msBrown
        self.layer.borderColor = UIColor.msBrown.cgColor
        self.layer.borderWidth = 1
        self.tintColor = .darkGray
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius ?? self.bounds.height/2
    }
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
    //add suffix
    func addSuffix(withText text: String, font: UIFont? = nil) {
        let prefix = UILabel()
        prefix.text = text
        if let font = font {
            prefix.font = font
        }
        prefix.sizeToFit()
        
        rightView = prefix
        rightViewMode = .always
    }
    
    //add prefix
    func addPrefix(withText text: String, font: UIFont? = nil) {
        let prefix = UILabel()
        prefix.text = text
        if let font = font {
            prefix.font = font
        }
        prefix.sizeToFit()
        
        leftView = prefix
        leftViewMode = .always
    }
}

/* Allowed Char Textfield Subclass */
class AllowedCharsTextField: UITextField, UITextFieldDelegate {
    @IBInspectable var allowedChars: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        autocorrectionType = .no
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count > 0 else {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return prospectiveText.containsOnlyCharactersIn(matchCharacters: allowedChars)
    }
}

class DigitsOnlyTextField: AllowedCharsTextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        allowedChars = "1234567890"
    }
}

class AmountOnlyTextField: AllowedCharsTextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        allowedChars = "1234567890."
    }
}
/* Allowed Char Textfield Subclass */

/* Date Picker Textfield Subclass */
class DatePickerTF: UITextField {
    
    let datePicker = UIDatePicker()
    var dateFormat = "dd/MM/yyyy"
    
    let toolbar = UIToolbar();
    let doneButton = UIBarButtonItem(title: kLb.done.localized, style: .plain, target: self, action: #selector(doneHandler));
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: kLb.clear.localized, style: .plain, target: self, action: #selector(cancelHandler));
    
    override func didMoveToSuperview() {
        datePicker.datePickerMode = .date
        
        inputAccessoryView = toolbar
        inputView = datePicker
        
        toolbar.sizeToFit()
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func doneHandler(){
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        text = formatter.string(from: datePicker.date)
        resignFirstResponder()
    }
    
    @objc func cancelHandler(){
        text = nil
        resignFirstResponder()
    }
}
/* Date Picker Textfield Subclass */
