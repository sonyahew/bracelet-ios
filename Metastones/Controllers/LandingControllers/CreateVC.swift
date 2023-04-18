//
//  CreateVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class CreateVC: UIViewController {
    
    weak var delegate: MenuDelegate?
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnCart: UIButton!
    
    //cart indicator
    @IBOutlet weak var vwIndicator: UIView!
    @IBOutlet weak var lbIndicator: UILabel!
    
    //controller
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var tfDOB: DatePickerTF!
    @IBOutlet weak var tfTOB: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var lbSkipColorBalance: UILabel!
    @IBOutlet weak var lbCustomizeOwn: UILabel!
    
    @IBOutlet weak var btnSubmit: BrownButton!
    @IBOutlet weak var btnFavList: ReversedBrownButton!
    @IBOutlet weak var btnCustom: BrownButton!
    
    @IBOutlet weak var vwDashLine: UIView!
    @IBOutlet weak var ivBracelet: UIImageView!
    
    let appData = AppData.shared
    let popupManager = PopupManager.shared
    let homeViewModel = HomeViewModel()
    let titles = [kLb.date_of_birth.localized, kLb.time_of_birth.localized, kLb.gender.localized]
    let placeholders = [kLb.dd_mm_yyyy.localized, kLb.hour_optional.localized, kLb.select_gender.localized]
    
    var day: String? = ""
    var month: String? = ""
    var year: String? = ""
    var hour: String? = ""
    var gender: String? = ""
    var selectedHour: Int? = 0
    var selectedGender: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCartIndicator()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lbIndicator.text = "\(appData.data?.cartItemCount ?? 0)"
        self.btnLive.hideShowBtnLive()
    }
    
    func setupCartIndicator() {
        vwIndicator.applyCornerRadius(cornerRadius: vwIndicator.bounds.height/2)
    }
    
    func setupView() {
        lbTitle.text = kLb.personalized.localized
        lbSubtitle.text = kLb.what_bracelet_is_right_for_your_date_of_birth.localized
        lbSkipColorBalance.text = kLb.skip_color_balance.localized
        lbCustomizeOwn.text = kLb.customize_own_bracelet.localized
        
        btnSubmit.setTitle(kLb.submit.localized, for: .normal)
        btnFavList.setTitle(kLb.bazi_book_lists.localized, for: .normal)
        btnCustom.setTitle(kLb.customize_now.localized, for: .normal)
        
        lbSkipColorBalance.isHidden = true
        ivBracelet.isHidden = true
        lbCustomizeOwn.isHidden = true
        btnCustom.isHidden = true
        //drawDottedLine(start: CGPoint(x: vwDashLine.bounds.minX, y: vwDashLine.bounds.minY), end: CGPoint(x: vwDashLine.bounds.maxX, y: vwDashLine.bounds.minY), view: vwDashLine)
        
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
        
        for (index, tf) in [tfDOB, tfTOB, tfGender].enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
        }
        
        for btn in [btnSubmit, btnCustom] {
            //btn?.addShadow(withRadius: 8, opacity: 1, color: UIColor.msBrown.cgColor, offset: CGSize(width: 0, height: 6))
        }
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(hex: 0xBCBCBC).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [6, 6]

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func menuHandler(_ sender: Any) {
        delegate?.showHideMenu()
    }
    
    @IBAction func cartHandler(_ sender: Any) {
        if isMemberUser(vc: self.navigationController) {
            navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
        }
    }
    
    @IBAction func liveHandler(_ sender: Any) {
        enterFbLive()
    }
    
    @IBAction func submitHandler(_ sender: Any) {
        if let day = day, day != "" {
            homeViewModel.calculateBazi(year: year, month: month, day: day, hour: hour, gender: gender) { (proceed, data) in
                if proceed {
                    var hourStr: String?
                    if let hour = self.hour, hour != "" {
                        hourStr = "\(hour):00:00"
                    }
                    var dobStr = "\(day)/\(self.month ?? "")/\(self.year ?? "") \(hourStr ?? "")\n"
                    
                    if self.appData.isLoggedIn {
                        self.popupManager.showAlert(destVC: self.popupManager.getSaveDOBPopup(title: kLb.do_you_want_to_save_this_date_of_birth.localized, leftBtnTitle: kLb.save.localized, rightBtnTitle: kLb.no_thanks.localized, year: self.year, month: self.month, day: self.day, hour: self.hour, gender: self.gender)) { (btnTitle, userData) in
                            
                            if btnTitle == kLb.save.localized {
                                self.popupManager.showAlert(destVC: self.popupManager.getSuccessPopup(title: kLb.successfully_saved_into_bazi_book_list.localized, desc: "")) { (btnTitle) in
                                    if let userData = userData {
                                        dobStr = "\(userData)\n\(dobStr)"
                                    }
                                    
                                    let colorBalanceVC = getVC(sb: "Landing", vc: "ColorBalanceVC") as! ColorBalanceVC
                                    colorBalanceVC.bzData = data?.data
                                    colorBalanceVC.userNameDOB = dobStr
                                    self.navigationController?.pushViewController(colorBalanceVC, animated: true)
                                }
                            } else {
                                let colorBalanceVC = getVC(sb: "Landing", vc: "ColorBalanceVC") as! ColorBalanceVC
                                colorBalanceVC.bzData = data?.data
                                colorBalanceVC.userNameDOB = dobStr
                                self.navigationController?.pushViewController(colorBalanceVC, animated: true)
                            }
                        }
                    } else {
                        let colorBalanceVC = getVC(sb: "Landing", vc: "ColorBalanceVC") as! ColorBalanceVC
                        colorBalanceVC.bzData = data?.data
                        colorBalanceVC.userNameDOB = dobStr
                        self.navigationController?.pushViewController(colorBalanceVC, animated: true)
                    }
                }
            }
            
        } else {
            popupManager.showAlert(destVC: popupManager.getAlertPopup(desc: kLb.date_of_birth_is_required.localized))
        }
    }
    
    @IBAction func favHandler(_ sender: Any) {
        if isMemberUser(vc: self.navigationController) {
            self.navigationController?.pushViewController(getVC(sb: "Profile", vc: "FavouriteListVC"), animated: true)
        }
    }
    
    @IBAction func customizeHandler(_ sender: Any) {
        let personalizedVC = getVC(sb: "Create", vc: "PersonalizedVC") as! PersonalizedVC
        personalizedVC.baziBalance = ""
        self.navigationController?.pushViewController(personalizedVC, animated: true)
    }
}

extension CreateVC: UITextFieldDelegate {
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
