//
//  LanguageVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol LanguageVCDelegate: class {
    func langUpdated()
}

class LanguageVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lbLanguage: UILabel!
    @IBOutlet weak var ivBg: UIImageView!
    
    let appData = AppData.shared
    let loginViewModel = LoginViewModel()
    var isPush : Bool = false
    var languageList : [LanguageDataModel?]?
    
    weak var delegate: LanguageVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isPush {
            ivBg.isHidden = true
            let blurEffect = UIBlurEffect.init(style: .regular)
            let blurEffectView = UIVisualEffectView.init(effect: blurEffect)
            blurEffectView.frame = UIScreen.main.bounds
            blurEffectView.alpha = 0.5
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.isUserInteractionEnabled = true
            let tapOutside = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
            blurEffectView.addGestureRecognizer(tapOutside)
            self.view.addSubview(blurEffectView)
            self.view.bringSubviewToFront(containerView)
        }
        lbLanguage.text = kLb.language.localized
        setupData()
    }
    
    func setupData() {
        loginViewModel.getLanguage { (proceed, data) in
            if proceed {
                self.languageList = data?.data?.language
                if self.languageList?.count ?? 0 <= 1 {
                    self.selectedLangId(langId: "en")
                } else {
                    self.setupLanguagesStack()
                }
            }
        }
    }
    
    func setupLanguagesStack() {
        let languages = self.languageList?.map({$0?.name?.localized})

        containerView.applyCornerRadius(cornerRadius: 38)
        containerView.heightAnchor.constraint(equalToConstant: CGFloat((languages?.count ?? 0+1)*80)).isActive = true
        
        for (index, language) in (languages ?? []).enumerated() {
            let vw = UIView()
            vw.backgroundColor = .white
            vw.tag = index
            let tapLanguage = UITapGestureRecognizer(target: self, action: #selector(self.didTapLanguage(_:)))
            vw.addGestureRecognizer(tapLanguage)
            
            let lb = UILabel()
            lb.textColor = .msBrown
            lb.text = language
            lb.font = .boldSystemFont(ofSize: 14)
            
            vw.addSubview(lb)
            lb.translatesAutoresizingMaskIntoConstraints = false
            lb.centerXAnchor.constraint(equalTo: vw.centerXAnchor).isActive = true
            lb.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
            
            stackView.addArrangedSubview(vw)
        }
    }
    
    @objc
    func didTapLanguage(_ sender: UITapGestureRecognizer? = nil) {
        if let index = sender?.view?.tag, let langId = languageList?[index]?.locale {
            selectedLangId(langId: langId)
        }
    }
    
    func selectedLangId(langId: String) {
        appData.data?.langId = langId
        loginViewModel.saveMobileInfo(needRetry: true) { (proceed, data) in
            if proceed {
                self.delegate?.langUpdated()
                self.dismissVC()
            }
        }
    }
    
    @objc
    func dismissVC() {
        if isPush {
            navigationController?.pushViewController(getVC(sb: "Landing", vc: "MenuVC"), animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
