//
//  GeneralPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 06/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import Lottie

protocol GeneralPopupDelegate: class {
    func tapBtnLeft(sourceVC : GeneralPopupVC)
    func tapBtnRight(sourceVC : GeneralPopupVC)
}

enum LottieStyle {
    case success
    case warning
    case fail
    case comingSoon
    case custom
}

class GeneralPopupVC: UIViewController {
    
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var btnLeft: BrownButton!
    @IBOutlet weak var btnRight: ReversedBrownButton!
    @IBOutlet weak var svButtons: UIStackView!
    
    @IBOutlet weak var lottieContainer: UIView!
    
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleConstraint: NSLayoutConstraint!
    @IBOutlet weak var descConstraint: NSLayoutConstraint!
    
    weak var delegate: GeneralPopupDelegate?
    
    var popupTitle: String = ""
    var desc: String = ""
    var descAlign: NSTextAlignment = .center
    var leftBtnTitle: String = ""
    var rightBtnTitle: String = ""
    var lottieStyle: LottieStyle = .warning
    var lottieStyleName: String = "success_anim"
    var isShowSingleBtn = false
    var isShowNoBtn = false
    
    var isVertical = false
    
    @IBAction func actionBtnLeft(_ sender: Any) {
        delegate?.tapBtnLeft(sourceVC: self)
    }
    
    @IBAction func actionBtnRight(_ sender: Any) {
        delegate?.tapBtnRight(sourceVC: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwContainer.applyCornerRadius(cornerRadius: 10)
        
        switch lottieStyle {
        case .success:
            lottieStyleName = "successAnim"
        case .fail:
            lottieStyleName = "errorAnim"
        case .warning:
            lottieStyleName = "warningAnim"
        case .comingSoon:
            let ivComingSoon = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            ivComingSoon.image = #imageLiteral(resourceName: "smiley.jpg")
            ivComingSoon.contentMode = .scaleAspectFit
            lottieContainer.addSubviewAndPinEdges(ivComingSoon, padding: -72)
        case.custom:
            lottieContainer.isHidden = true
            imageConstraint.constant = 100
        }
        if lottieStyle != .comingSoon || lottieStyle != .custom {
            let lottie = AnimationView(name: lottieStyleName)
            lottieContainer.addSubviewAndPinEdges(lottie)
            lottie.play()
        }
        
        if isShowSingleBtn {
            svButtons.arrangedSubviews[1].isHidden = isShowSingleBtn
            
        } else if isShowNoBtn {
            svButtons.arrangedSubviews[0].isHidden = isShowNoBtn
            svButtons.arrangedSubviews[1].isHidden = isShowNoBtn
        }
        
        if desc == "" {
            descConstraint.constant = 6
        }
        
        if popupTitle == "" {
            titleConstraint.constant = -4
        }
        
        lbTitle.text = popupTitle
        lbDesc.text = desc
        lbDesc.textAlignment = descAlign
        btnLeft.setTitle(leftBtnTitle, for: .normal)
        btnRight.setTitle(rightBtnTitle, for: .normal)
        
        if isVertical {
            svButtons.axis = .vertical
            svButtons.spacing = 6
        } else {
            svButtons.axis = .horizontal
            svButtons.spacing = 16
        }
    }
}
