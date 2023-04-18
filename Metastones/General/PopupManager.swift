//
//  PopupManager.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class PopupManager {
    
    typealias popupCompletion = (_ btnTitle : String?) -> Void
    typealias popupDataCompletion = (_ btnTitle : String?, _ data : String?) -> Void
    static let shared = PopupManager()
    
    var topSuperview : UIViewController?
    var popupCompletionBlock : popupCompletion?
    var popupDataCompletionBlock : popupDataCompletion?
    
    func showAlert(destVC : UIViewController) {
        showAlert(destVC: destVC) { _  in }
    }
    
    func showAlert(destVC : UIViewController,  completion: @escaping popupCompletion) {
        popupCompletionBlock = completion
        setupPopupScreen(destVC: destVC)
    }
    
    func showAlert(destVC : UIViewController,  completion: @escaping popupDataCompletion) {
        popupDataCompletionBlock = completion
        setupPopupScreen(destVC: destVC)
    }
    
    private func setupPopupScreen(destVC : UIViewController) {
        DispatchQueue.main.async {
            let vc = baseController()
            self.topSuperview = vc
            
            let blurEffect = UIBlurEffect.init(style: .dark)
            let blurEffectView = UIVisualEffectView.init(effect: blurEffect)
            blurEffectView.frame = UIScreen.main.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            vc.addChild(destVC)
            
            destVC.view.alpha = 0.0
            blurEffectView.alpha = 0.0
            vc.view.addSubview(blurEffectView)
            vc.view.addSubview(destVC.view)
            
            UIView.animate(withDuration: 0.3, animations: {
                blurEffectView.alpha = 0.5
                destVC.view.alpha = 1.0
            })
            
            destVC.didMove(toParent: vc)
        }
    }
    
    private func removePopupScreen(sourceVC : UIViewController) {
        DispatchQueue.main.async {
            let vc = self.topSuperview
            
            for view in vc?.view.subviews.reversed() ?? [] {
                if view.isKind(of: UIVisualEffectView.classForCoder()) {
                    view.removeFromSuperview()
                    break
                }
            }
            
            sourceVC.willMove(toParent: nil)
            sourceVC.view.removeFromSuperview()
            sourceVC.removeFromParent()
        }
    }
}

//MARK:- GENERAL POPUP
extension PopupManager: GeneralPopupDelegate {
    func getGeneralPopup(title : String? = nil, desc : String?, strLeftText: String?, strRightText: String? = nil, style: LottieStyle, isShowSingleBtn: Bool? = false, isShowNoBtn: Bool? = false, descAlign: NSTextAlignment? = .center, isVertical: Bool? = false) -> GeneralPopupVC {

        let alertPopupVC = getVC(sb: "Popup", vc: "GeneralPopupVC") as! GeneralPopupVC
        alertPopupVC.popupTitle = title ?? ""
        alertPopupVC.desc = desc ?? ""
        alertPopupVC.descAlign = descAlign ?? .center
        alertPopupVC.leftBtnTitle = strLeftText ?? ""
        alertPopupVC.rightBtnTitle = strRightText ?? ""
        alertPopupVC.delegate = self
        alertPopupVC.lottieStyle = style
        alertPopupVC.isShowSingleBtn = isShowSingleBtn ?? false
        alertPopupVC.isShowNoBtn = isShowNoBtn ?? false
        alertPopupVC.isVertical = isVertical ?? false
        return alertPopupVC
    }
    
    func getSuccessPopup(title : String? = nil, desc : String? = "", strBtnText: String? = nil) -> GeneralPopupVC {
        return getGeneralPopup(title: title, desc: desc ?? "", strLeftText: strBtnText ?? kLb.ok.localized, style: .success, isShowSingleBtn: true)
    }

    func getErrorPopup(title : String? = nil, desc : String? = "", strBtnText: String? = nil) -> GeneralPopupVC {
        return getGeneralPopup(title: kLb.error.localized, desc: desc ?? "", strLeftText: strBtnText ?? kLb.ok.localized, style: .fail, isShowSingleBtn: true)
    }

    func getAlertPopup(title : String? = nil, desc : String? = "", strBtnText: String? = nil) -> GeneralPopupVC {
        return getGeneralPopup(title: title, desc: desc ?? "", strLeftText: strBtnText ?? kLb.ok.localized, style: .warning, isShowSingleBtn: true)
    }
    
    func getAlertNoBtnPopup(title : String? = nil, desc : String? = "") -> GeneralPopupVC {
        return getGeneralPopup(title: title, desc: desc ?? "", strLeftText: "", style: .warning, isShowNoBtn: true)
    }
    
    func getLogoutPopup(title: String? = nil) -> GeneralPopupVC {
        return getGeneralPopup(title: title ?? "", desc: "", strLeftText: kLb.ok.localized, strRightText: kLb.cancel.localized, style: .warning)
    }
    
    func getComingSoonPopup(title : String? = nil, desc : String? = "", strBtnText: String? = nil) -> GeneralPopupVC {
        return getGeneralPopup(title: title, desc: desc ?? "", strLeftText: strBtnText ?? kLb.ok.localized, style: .comingSoon, isShowSingleBtn: true)
    }
    
    func getMsgOnlyPopup(desc: String? = "") -> GeneralPopupVC {
        return getGeneralPopup(title: "", desc: desc ?? "", strLeftText: kLb.ok.localized, style: .custom, isShowSingleBtn: true)
    }
    
    func getTitleMsgOnlyPopup(title: String? = "", desc: String? = "", btnTitle: String? = "") -> GeneralPopupVC {
        return getGeneralPopup(title: title ?? "", desc: desc ?? "", strLeftText: btnTitle ?? kLb.ok.localized, style: .custom, isShowSingleBtn: true, descAlign: .left)
    }
    
    func tapBtnLeft(sourceVC: GeneralPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.leftBtnTitle)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
    
    func tapBtnRight(sourceVC: GeneralPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.rightBtnTitle)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- SaveDOB Popup
extension PopupManager: SaveDOBPopupVCDelegate {
    
    func getSaveDOBPopup(title: String? = nil, leftBtnTitle: String?, rightBtnTitle: String?, year: String?, month: String?, day: String?, hour: String?, gender: String?) -> SaveDOBPopupVC {
        let saveDOBPopup = getVC(sb: "Popup", vc: "SaveDOBPopupVC") as! SaveDOBPopupVC
        saveDOBPopup.popupTitle = title ?? ""
        saveDOBPopup.leftBtnTitle = leftBtnTitle ?? ""
        saveDOBPopup.rightBtnTitle = rightBtnTitle ?? ""
        saveDOBPopup.year = year
        saveDOBPopup.month = month
        saveDOBPopup.day = day
        saveDOBPopup.hour = hour
        saveDOBPopup.gender = gender
        saveDOBPopup.delegate = self
        
        return saveDOBPopup
    }
    
    func tapBtnLeft(sourceVC: SaveDOBPopupVC) {
        if let popupCompletionBlock = popupDataCompletionBlock {
            popupCompletionBlock(sourceVC.leftBtnTitle, sourceVC.tfMobileNo.text)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
    
    func tapBtnRight(sourceVC: SaveDOBPopupVC) {
        if let popupCompletionBlock = popupDataCompletionBlock {
            popupCompletionBlock(sourceVC.rightBtnTitle, sourceVC.tfMobileNo.text)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}


//MARK:- ResetPassword Popup
extension PopupManager: ResetPasswordPopupDelegate {
    
    func getResetPasswordPopup() -> ResetPwPopupVC {
        let resetPwPopupVC = getVC(sb: "Popup", vc: "ResetPwPopupVC") as! ResetPwPopupVC
        resetPwPopupVC.btnTitle = "submit"
        resetPwPopupVC.delegate = self
        
        return resetPwPopupVC
    }
    
    func tapBtnSubmit(sourceVC: ResetPwPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.btnTitle)
        }
        removePopupScreen(sourceVC: sourceVC)
    }

}

//MARK:- OTP Popup
extension PopupManager: VerifyPopupDelegate {
    
    func getOTPPopup(validSec: Int, fullName: String? = nil, prefix: String? = nil, mobileNo: String? = nil, email: String? = nil, nric: String? = nil, bankTypeId: String? = nil, bankAccNo: String? = nil, withdrawAmt: String? = nil) -> VerifyPopupVC {
        let verifyPopup = getVC(sb: "Popup", vc: "VerifyPopupVC") as! VerifyPopupVC
        verifyPopup.maskedMobileNo = "\(prefix ?? "")\(mobileNo ?? "")".safeMobileNo()
        verifyPopup.validSec = validSec
        
        verifyPopup.fullName = fullName
        verifyPopup.prefix = prefix
        verifyPopup.mobileNo = mobileNo
        verifyPopup.email = email
        verifyPopup.nric = nric
        verifyPopup.bankTypeId = bankTypeId
        verifyPopup.bankAccNo = bankAccNo
        verifyPopup.withdrawAmt = withdrawAmt
        
        verifyPopup.delegate = self
        
        return verifyPopup
    }
    
    func tapDismiss(sourceVC: VerifyPopupVC, message: String) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(message)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- Welcome Popup
extension PopupManager: WelcomePopupDelegate {
    
    func getWelcomePopup(title: String, metaCoins: String, points: String, isClaim: Bool? = true) -> WelcomePopupVC {
        let welcomePopup = getVC(sb: "Popup", vc: "WelcomePopupVC") as! WelcomePopupVC
        welcomePopup.lbTitle = title
        welcomePopup.pointsValue = metaCoins
        welcomePopup.points = points
        welcomePopup.isClaim = isClaim ?? true
        welcomePopup.delegate = self
        
        return welcomePopup
    }
    
    func tapBtnSubmit(sourceVC: WelcomePopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.btnRedeem.titleLabel?.text)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- Forgot Password Popup
extension PopupManager: ForgotPassPopupVCDelegate {
    
    func getForgotPassPopup() -> ForgotPassPopupVC {
        let forgotPassPopup = getVC(sb: "Popup", vc: "ForgotPassPopupVC") as! ForgotPassPopupVC
        forgotPassPopup.popupTitle = kLb.please_enter_your_email_address.localized
        forgotPassPopup.leftBtnTitle = kLb.ok.localized
        forgotPassPopup.rightBtnTitle = kLb.cancel.localized
        forgotPassPopup.delegate = self
        
        return forgotPassPopup
    }
    
    func tapBtnLeft(sourceVC: ForgotPassPopupVC) {
        
        let popupManager = PopupManager.shared
        if let email = sourceVC.tfEmail.text, email != "" {
            LoginViewModel().forgotPass(email: email) { (proceed, data) in
                if proceed {
                    popupManager.showAlert(destVC: popupManager.getSuccessPopup(desc: data?.msg)) { (btnTitle) in
                        if let popupCompletionBlock = self.popupCompletionBlock {
                            popupCompletionBlock(sourceVC.leftBtnTitle)
                        }
                        self.removePopupScreen(sourceVC: sourceVC)
                    }
                }
            }
        } else {
            popupManager.showAlert(destVC: popupManager.getErrorPopup(desc: kLb.field_is_required.localized))
        }
    }
    
    func tapBtnRight(sourceVC: ForgotPassPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.rightBtnTitle)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- Notifications Popup
extension PopupManager: NotiPopupDelegate {
    
    func getNotiPopup(title: String, desc: String) -> NotiPopupVC {
        let notiPopup = getVC(sb: "Popup", vc: "NotiPopupVC") as! NotiPopupVC
        notiPopup.notiTitle = title
        notiPopup.desc = desc
        notiPopup.delegate = self
        
        return notiPopup
    }
    
    func tapBtn(sourceVC: NotiPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.title)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- QR Popup
extension PopupManager: QRPopupVCDelegate {
    
    func getQRPopup(referralUrl: String) -> QRPopupVC {
        let qrPopup = getVC(sb: "Popup", vc: "QRPopupVC") as! QRPopupVC
        qrPopup.delegate = self
        qrPopup.referralUrl = referralUrl
        
        return qrPopup
    }
    
    func tapClose(sourceVC: QRPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.btnRight.titleLabel?.text)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- ColorBal Popup
extension PopupManager: ColorBalPopupVCDelegate {
    
    func getColorBalPopup(delegate: CustomizeTVCDelegate) -> ColorBalPopupVC {
        let colorBalPopup = getVC(sb: "Popup", vc: "ColorBalPopupVC") as! ColorBalPopupVC
        colorBalPopup.tapDelegate = self
        colorBalPopup.delegate = delegate
        
        return colorBalPopup
    }
    
    func tapSubmit(sourceVC: ColorBalPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.btnSubmit.titleLabel?.text)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- Sign Up Success Popup
extension PopupManager: SignUpSuccessPopupVCDelegate {
    
    func getSignUpSuccessPopup() -> SignUpSuccessPopupVC {
        let signUpSuccessPopup = getVC(sb: "Popup", vc: "SignUpSuccessPopupVC") as! SignUpSuccessPopupVC
        signUpSuccessPopup.delegate = self
        return signUpSuccessPopup
    }
    
    func tapClose(sourceVC: SignUpSuccessPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock("")
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

//MARK:- Create Acc Popup
extension PopupManager: CreateAccPopupVCDelegate {
    
    func getCreateAccPopup(mobile: String, email: String, checkoutId: String, orderDetailsVC: OrderDetailsVC, isAcademy: Bool) -> CreateAccPopupVC {
        let createAccPopup = getVC(sb: "Popup", vc: "CreateAccPopupVC") as! CreateAccPopupVC
        createAccPopup.mobile = mobile
        createAccPopup.email = email
        createAccPopup.delegate = self
        createAccPopup.checkoutId = checkoutId
        createAccPopup.orderDetailsVC = orderDetailsVC
        createAccPopup.isAcademy = isAcademy
        return createAccPopup
    }
    
    func tapBtnLeft(sourceVC: CreateAccPopupVC) {
        
        let popupManager = PopupManager.shared
        if let password = sourceVC.tfPassword.text, password != "", let cfmPassword = sourceVC.tfRetype.text, cfmPassword != "" {
            LoginViewModel().guestSignup(password: password, cfmPassword: cfmPassword, checkoutId: sourceVC.checkoutId, isAcademy: sourceVC.isAcademy) { (proceed, data) in
                if proceed {
                    popupManager.showAlert(destVC: popupManager.getSuccessPopup(desc: data?.msg)) { (btnTitle) in
                        self.removePopupScreen(sourceVC: sourceVC)
                        sourceVC.orderDetailsVC.vwSignup.isHidden = true
                    }
                }
            }
        } else {
            popupManager.showAlert(destVC: popupManager.getErrorPopup(desc: kLb.field_is_required.localized))
        }
    }
    
    func tapBtnRight(sourceVC: CreateAccPopupVC) {
        if let popupCompletionBlock = popupCompletionBlock {
            popupCompletionBlock(sourceVC.rightBtnTitle)
        }
        removePopupScreen(sourceVC: sourceVC)
    }
}

