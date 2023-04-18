//
//  QRPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 06/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol QRPopupVCDelegate: class {
    func tapClose(sourceVC : QRPopupVC)
}

class QRPopupVC: UIViewController {

    @IBOutlet weak var ivQR: UIImageView!
    @IBOutlet weak var lbQR: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnLeft: BrownButton!
    @IBOutlet weak var btnRight: ReversedBrownButton!
    
    weak var delegate: QRPopupVCDelegate?
    var referralUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if referralUrl != "" {
            ivQR.image = QRCodeHelper().generateQrCode(content: referralUrl)
        } else {
            ivQR.image = #imageLiteral(resourceName: "no-image")
        }
        lbQR.text = referralUrl
        btnLeft.setTitle(kLb.share.localized.capitalized, for: .normal)
        btnRight.setTitle(kLb.close.localized.capitalized, for: .normal)
    }
    
    @IBAction func copyHandler(_ sender: Any) {
        copyToPasteboard(str: referralUrl)
    }
    
    @IBAction func shareHandler(_ sender: Any) {
        self.present(getShareActivity(shareItems: [referralUrl], sourceView: btnLeft), animated: true)
    }
    
    @IBAction func closeHandler(_ sender: Any) {
        delegate?.tapClose(sourceVC: self)
    }
    
}
