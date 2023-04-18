//
//  WelcomePopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 14/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol WelcomePopupDelegate: class {
    func tapBtnSubmit(sourceVC : WelcomePopupVC)
}

class WelcomePopupVC: UIViewController {
    
    weak var delegate: WelcomePopupDelegate?

    @IBOutlet weak var vwContainer: UIView!
    
    @IBOutlet weak var lbWelcomeGift: UILabel!
    @IBOutlet weak var lbPoints: UILabel!
    @IBOutlet weak var lbPointsValue: UILabel!
    
    @IBOutlet weak var ivGiftLid: UIImageView!
    @IBOutlet weak var ivGiftBox: UIImageView!
    @IBOutlet weak var lidBtmConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnRedeem: BrownButton!
    
    let homeViewModel = HomeViewModel()
    
    var isLidLifted = false
    var lbTitle: String = ""
    var pointsValue: String = ""
    var points: String = ""
    var isClaim: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbWelcomeGift.text = lbTitle.localized
        lbPoints.text = points
        lbPointsValue.text = pointsValue
        lbPoints.alpha = 0
        lbPointsValue.alpha = 0
        btnRedeem.setTitle(kLb.redeem_now.localized.capitalized, for: .normal)
    }
    
    @IBAction func redeemHandler(_ sender: Any) {
        if !isLidLifted {
            if isClaim {
                homeViewModel.claimRewards(rewardType: lbTitle) { (proceed, data) in
                    if proceed {
                        self.liftLid()
                    }
                }
            } else {
                liftLid()
            }
            
        } else {
            delegate?.tapBtnSubmit(sourceVC: self)
        }
        isLidLifted = !isLidLifted
    }
    
    func liftLid() {
        self.lidBtmConstraint.constant = -82
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.5, delay: 0.2, animations: {
                    self.lbPoints.alpha = 1
                    self.lbPointsValue.alpha = 1
                }, completion: { (done) in
                    if done {
                        self.btnRedeem.setTitle(kLb.close.localized.capitalized, for: .normal)
                    }
                })
            }
        })
    }
}
