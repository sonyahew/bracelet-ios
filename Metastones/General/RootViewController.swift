//
//  ViewController.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    let appData = AppData.shared
    let viewModel = ViewModelBase()
    let loginViewModel = LoginViewModel()
    let popupManager = PopupManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = .white
        
        let bgView = UIImageView()
        bgView.contentMode = .scaleAspectFill
        bgView.frame = self.view.frame
        bgView.image = #imageLiteral(resourceName: "bg-splash")
        
        self.view.addSubview(bgView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appData.loadAppData()
        getStartupAPI()
    }
    
    private func getStartupAPI() {
        
        viewModel.getTranslations { (proceed, data) in
            if proceed {
                self.viewModel.getAppVersion { (proceed, data) in
                    if proceed {
                        let appVersionData = data?.data
                        
                        if appVersionData?.maintenance == 1 {
                            self.popupManager.showAlert(destVC: self.popupManager.getAlertNoBtnPopup(desc: appVersionData?.maintenanceMsg?.localized))
                            
                        } else if appVersionData?.update == 1 {
                            self.popupManager.showAlert(destVC: self.popupManager.getGeneralPopup(desc: appVersionData?.updateMsg?.localized, strLeftText: kLb.update.localized, style: .warning, isShowSingleBtn: true)) { (btnTitle) in
                                openUrl(url: appVersionData?.storeUrl)
                            }
                            
                        } else {
                            self.viewModel.getAppSetting { (proceed, data) in
                                if proceed {
                                    self.navigateStartUp()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func navigateStartUp() {
        if !self.appData.isLoggedIn {
            viewModel.getSessionId { (proceed, data) in
                if proceed {
                    let userDefaults = UserDefaults.standard
                    
                    if !userDefaults.bool(forKey: hasRunBefore) {
                        userDefaults.set(true, forKey: hasRunBefore)
                        let languageListVC = getVC(sb: "Main", vc: "LanguageVC") as! LanguageVC
                        languageListVC.isPush = true
                        self.navigationController?.pushViewController(languageListVC, animated: true)
                        
                    } else {
                        self.navigateToLanding()
                    }
                }
            }

        } else {
            viewModel.getProfile(needRetry: true) { (proceed, data) in
                if proceed {
                    self.navigateToLanding()
                }
            }
        }
    }
    
    private func navigateToLanding() {
        navigationController?.pushViewController(getVC(sb: "Landing", vc: "MenuVC"), animated: true)
    }
}

