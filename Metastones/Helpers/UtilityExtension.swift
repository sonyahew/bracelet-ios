//
//  UtilityExtension.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import LocalAuthentication
import AVFoundation
import FittedSheets
import SVProgressHUD
import Kingfisher

var isSmallScreen: Bool {
    return UIScreen.main.nativeBounds.height <= 1136 ? true : false
}

func baseController() -> UIViewController {
    var topViewController = UIApplication.shared.keyWindow?.rootViewController
    
    while topViewController?.presentedViewController != nil {
        topViewController = topViewController?.presentedViewController
    }
    
    return topViewController ?? UIViewController()
}

func getVC(sb: String, vc: String) -> UIViewController {
    let vc = UIStoryboard(name: sb, bundle: nil).instantiateViewController(withIdentifier: vc)
    return vc
}

func getViewControllerFromStackFor(viewController:UIViewController, currVC:UIViewController) -> UIViewController {
    var i = 0
    var arrVC = [UIViewController]()
    
    if let arrViewControllers = currVC.navigationController{
        
        arrVC = arrViewControllers.viewControllers.reversed()
        for vc in arrVC{
            if vc.isKind(of: viewController.classForCoder){
                break
            }
            i += 1
        }
    }
    
    return arrVC[i]
}

func showActionSheet(title: String?, message: String?, totalButton: [Any]?, fromVC vc: UIViewController?, sourceView: UIView?, completion: @escaping (_ alertController: UIAlertController, _ buttonIndex: Int, _ buttonTitle: String) -> Void)
{
    var title = title
    var message = message
    var vc = vc
    
    title = ((title?.count ?? 0) == 0) ? "" : title
    message = ((message?.count ?? 0) == 0) ? "" : message
    
    if let totalButton = totalButton, totalButton.count > 0 {
        let theButtonArray = totalButton
        
        var alertController: UIAlertController? = nil
        var alertAction: UIAlertAction? = nil
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for count in 0..<theButtonArray.count {
            
            let buttonTitle = theButtonArray[count] as? String
            
            alertAction = UIAlertAction(title: buttonTitle, style: .default, handler: { action in
                completion(alertController!, count, buttonTitle ?? "")
            })
            
            if let alertAction = alertAction {
                alertController?.addAction(alertAction)
            }
        }
        
        alertAction = UIAlertAction(title: kLb.cancel.localized, style: .cancel, handler: { action in
            
        })
        
        if let alertAction = alertAction {
            alertController?.addAction(alertAction)
        }
        
        if vc == nil {
            vc = UIApplication.shared.keyWindow?.rootViewController
            while ((vc?.presentedViewController) != nil) {
                vc = vc?.presentedViewController
            }
        }
        
        if vc?.presentedViewController == nil {
            DispatchQueue.main.async(execute: {
                
                if let popoverController = alertController!.popoverPresentationController {
                    if sourceView == nil {
                        var frame: CGRect? = vc?.navigationController?.navigationBar.frame
                        frame?.origin.x = (vc?.navigationItem.leftBarButtonItem?.width)!
                        
                        popoverController.sourceView = vc!.view
                        popoverController.sourceRect = frame!
                        popoverController.barButtonItem = vc?.navigationItem.rightBarButtonItem
                    } else {
                        let frame = sourceView?.bounds
                        popoverController.sourceView = sourceView
                        popoverController.sourceRect = frame!
                    }
                }
                
                vc?.present(alertController!, animated: true, completion: nil)
            })
        }
    }
}

func copyToPasteboard(str: String) {
    let popupManager = PopupManager.shared
    
    UIPasteboard.general.string = str
    popupManager.showAlert(destVC: popupManager.getSuccessPopup(desc: ""))
}

func getShareActivity(shareItems : [Any], sourceView : UIView) -> UIActivityViewController {
    let activityViewController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = sourceView
    return activityViewController
}

func openUrl(url : String?) {
    if let url = URL(string: url ?? ""), UIApplication.shared.canOpenURL(url){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    } else {
        let popupManager = PopupManager.shared
        //popupManager.showAlert(destVC: popupManager.getAlertPopup(msg: kLb.sorry_your_action_cannot_be_completed.localized))
    }
}

enum BiometricType {
    case none
    case touch
    case face
}

func getBiometricType() -> BiometricType {
    let authContext = LAContext()
    if #available(iOS 11, *) {
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch(authContext.biometryType) {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        }
    } else {
        return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
    }
}

func biometricEnrolled() -> Bool {
    let laContext = LAContext.init()
    var authError : NSError? = nil
    
    if laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
        return authError?.code == Int(kLAErrorBiometryNotEnrolled) ? false : true
    }
    
    return false
}

func cameraPhotoLibraryHandler(msg : String, vc: UIViewController, view: UIView) {
    showActionSheet(title: "", message: msg, totalButton: [kLb.take_from_camera.localized, kLb.choose_from_gallery.localized], fromVC: vc, sourceView: view) { (alertController, btnIndex, btnTitle) in
        if btnTitle == kLb.take_from_camera.localized {
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied {
//                let popupManager = PopupManager.shared
//                popupManager.showAlert(destVC: popupManager.getGeneralPopup(title: kLb.error.localized, msg: kLb.camera_permission_denied.localized, strLeftText: kLb.setting.localized.capitalized, strRightText: kLb.cancel.localized.capitalized), completion: { (btnTitle) in
//                    if btnTitle?.capitalized == kLb.setting.localized.capitalized {
//                        openUrl(url: UIApplication.openSettingsURLString)
//                    }
//                })
            } else {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = vc as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                vc.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = vc as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            vc.present(imagePicker, animated: true, completion: nil)
        }
    }
}

func getSheetController(vc: UIViewController, size: CGFloat) -> SheetViewController {
    var sizes: [SheetSize] = []
    sizes.append(.fixed(size))
    
    let sheetController = SheetViewController(controller: vc, sizes: sizes)
    sheetController.blurBottomSafeArea = true
    sheetController.adjustForBottomSafeArea = true
    sheetController.extendBackgroundBehindHandle = true
    sheetController.topCornersRadius = 15
    
    return sheetController
}

var keyWindow: UIWindow? {
    get {
        return UIApplication.shared.keyWindow
    }
}

var loadingIndicator = LoadingIndicator.shared

func startLoading() {
    
    if let keyWindow = keyWindow {
        if keyWindow.subviews.contains(loadingIndicator) {
            
        } else {
            keyWindow.addSubviewAndPinEdges(loadingIndicator)
        }
    }

    //loadingIndicator.removeFromSuperview()
//    SVProgressHUD.setDefaultStyle(.light)
//    SVProgressHUD.setDefaultMaskType(.gradient)
//    SVProgressHUD.show()
}

func stopLoading() {
    DispatchQueue.main.async {
        loadingIndicator.removeFromSuperview()
    }
    //SVProgressHUD.dismiss()
}

class LoadingIndicator: UIView {
    
    static let shared = LoadingIndicator(displayOverlay: true)
    
    init(displayOverlay: Bool) {
        super.init(frame: CGRect.zero)
        let container = UIView()
        container.center = self.center
        self.isUserInteractionEnabled = displayOverlay
        container.isUserInteractionEnabled = displayOverlay
        container.backgroundColor = displayOverlay ? UIColor.black.withAlphaComponent(0.3) : .clear
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 68, height: 68))
        loadingView.center = container.center
        loadingView.backgroundColor = .white
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let indicator = UIImageView()
        if let path = Bundle.main.path(forResource: "metastones", ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            let provider = LocalFileImageDataProvider(fileURL: url)
            indicator.kf.setImage(with: provider)
        }
        indicator.frame = CGRect(x: 0, y: 0, width: 55, height: 30)
        indicator.center = CGPoint(x: loadingView.frame.width / 2, y: loadingView.frame.height / 2)
        loadingView.addSubview(indicator)
        
        container.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 68).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 68).isActive = true
        addSubviewAndPinEdges(container)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func getSheetedController(controller: UIViewController, sizes : [SheetSize], currentVC: UIViewController, completion: @escaping (UIViewController) -> Void) {
    
    controller.navigationController?.isNavigationBarHidden = true
    let sheetController = SheetViewController(controller: controller, sizes: sizes)
    sheetController.blurBottomSafeArea = false
    sheetController.extendBackgroundBehindHandle = true
    sheetController.handleColor = .clear
    sheetController.topCornersRadius = 15
    
    sheetController.didDismiss = { sc in
        completion(sc.childViewController)
    }
    
    // It is important to set animated to false or it behaves weird currently
    currentVC.present(sheetController, animated: false, completion: nil)
}

var hasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}

func deepLinkHandler(url : String?, navController: UINavigationController?) {
    if let urlString = url, !urlString.isEmpty, let yourTargetUrl = URL(string:urlString){
        var dict = [String:String]()
        let components = URLComponents(url: yourTargetUrl, resolvingAgainstBaseURL: false)!
        let scheme = components.scheme
        let host = components.host
        if let queryItems = components.queryItems {
            for item in queryItems {
                dict[item.name] = item.value ?? ""
            }
        }

        if scheme == "metastones" {
            switch host {
            case "share":
                //navController?.pushViewController(getVC(sb: "Profile", vc: "ReferVC"), animated: true)
                print("")
            case "product-page":
                if let productId = dict["id"], productId.isInt {
                    ProductViewModel().getProductDetails(productId: Int(productId)!) { (proceed, data) in
                        if proceed {
                            let vc = getVC(sb: "Landing", vc: "ProductDetailsVC") as! ProductDetailsVC
                            if let data = data {
                                vc.productDetailsData = data
                                navController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            case "product-category":
                let prdListVC = getVC(sb: "Landing", vc: "MenuVC") as! MenuVC
                prdListVC.selectedCode = dict["code"] ?? "ALL"
                menuOpened = false
                navController?.setViewControllers([prdListVC], animated: true)
                
            case "register":
                if !AppData.shared.isLoggedIn {
                    let signUpVC = getVC(sb: "Main", vc: "LoginPageVC") as! LoginPageVC
                    signUpVC.landingIndex = 1
                    navController?.pushViewController(signUpVC, animated: true)
                }
                
            case "create":
                let landingVC = getVC(sb: "Landing", vc: "MenuVC") as! MenuVC
                landingVC.toTab = 2
                menuOpened = false
                navController?.setViewControllers([landingVC], animated: true)
                
            default:
                return
            }
        
        } else {
            openUrl(url: urlString)
        }
    }
}

func isMemberUser(vc: UINavigationController?) -> Bool {
    if !AppData.shared.isLoggedIn {
        let loginVC = getVC(sb: "Main", vc: "LoginPageVC") as! LoginPageVC
        loginVC.landingIndex = 0
        vc?.pushViewController(loginVC, animated: true)
        return false
    }
    
    return true
}

//MARK:- Sheeted Picker
func getPickerSheetedController(title: String? = "", dataArr: [String], forVC vc: UIViewController, selectedRow: Int? = nil, completion: @escaping (_ buttonTitle: String?, _ buttonIndex: Int) -> Void) {
    let filterVC = getVC(sb: "Sheet", vc: "SizeVC") as! SizeVC
    filterVC.strTitle = title ?? ""
    filterVC.titles = dataArr
    if let selectedRow = selectedRow {
        filterVC.preselectRow = selectedRow
    }
    
    let header: CGFloat = 160
    let containerHeight: CGFloat = 88
    let btmPadding: CGFloat = hasTopNotch ? 48 : 0
    
    getSheetedController(controller: filterVC, sizes: [.fixed(header+containerHeight+btmPadding)], currentVC: vc) { (sc) in
        if !filterVC.isCancel {
            let selectedIndex = filterVC.pickerView.selectedRow(inComponent: 0)
            completion(dataArr[selectedIndex], selectedIndex)
        }
    }
}

//MARK:- Sheeted Dropdown
func showSheetedAction (title: String?, totalButton: [(selection: String, image: String?)]?, fromVC: UIViewController, completion: @escaping (_ buttonTitle: String?, _ buttonIndex: Int) -> Void) {
    
    let vc = getVC(sb: "Sheet", vc: "DropdownVC") as! DropdownVC
    vc.strTitle = title
    vc.selections = totalButton ?? []
    
    var sheetHeight : CGFloat = 10
    if let title = title, title != "" {
        sheetHeight += 60
    }
    if let totalButton = totalButton, totalButton.count > 0 {
        sheetHeight += (60*CGFloat(totalButton.count))
    }
    
    getSheetedController(controller: vc, sizes: [SheetSize.fixed(sheetHeight)], currentVC: fromVC) { (controller) in
        let dropDownVC = controller as! DropdownVC
        if let selectedValue = dropDownVC.selectedValue, let selectedIndex = dropDownVC.selectedIndex {
            completion(selectedValue, selectedIndex)
        }
    }
}


//MARK:- Attributed Total Price - .msBrown
func setupTotal(label: String, value: String, priceSize: CGFloat? = 16) -> NSAttributedString {
    let attribute = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: priceSize ?? 16), NSAttributedString.Key.foregroundColor : UIColor.msBrown]
    let labelText = NSAttributedString(string: "\(label): ")
    let valueText: NSMutableAttributedString = NSMutableAttributedString(string: value, attributes: attribute)
    let totalPrice = NSMutableAttributedString(attributedString: labelText)
    totalPrice.append(valueText)
    
    return totalPrice
}

func callFbLiveStatusAPI() {
    ViewModelBase().fbLiveStatus { (proceed, data) in
        if proceed {
            let appData = AppData.shared
            
            if let fbLiveList = data?.data?.fbLiveList, fbLiveList.count > 0 {
                appData.fbLiveData = fbLiveList
            }
            
            if let currentFbLive = data?.data?.currentLive, currentFbLive.fbLiveId != nil {
                appData.currentFbLive = currentFbLive
            } else {
                appData.currentFbLive = nil
            }
            
            if let vc = UIApplication.topViewController() {
                if vc.isKind(of: MenuVC.self) {
                    let finalVC = vc as! MenuVC
                    if let presentingVC = finalVC.landingVC.tabController.selectedViewController {
                        
                        if presentingVC.isKind(of: HomeVC.self) {
                            let finalVC = presentingVC as! HomeVC
                            finalVC.btnLive.hideShowBtnLive()
                            
                        } else if presentingVC.isKind(of: MetastonesVC.self) {
                            let finalVC = presentingVC as! MetastonesVC
                            finalVC.btnLive.hideShowBtnLive()
                            
                        } else if presentingVC.isKind(of: CreateVC.self) {
                            let finalVC = presentingVC as! CreateVC
                            finalVC.btnLive.hideShowBtnLive()
                        }
                    }
                }
            }
        }
    }
}

func enterFbLive() {
    let appData = AppData.shared
    if let currentFbLive = appData.currentFbLive {
        openUrl(url: currentFbLive.fbLiveLink)
    }
}
