//
//  NotiPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol NotiPopupDelegate: class {
    func tapBtn(sourceVC : NotiPopupVC)
}

class NotiPopupVC: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tvDesc: UITextView!
    @IBOutlet weak var btnDismiss: UIButton!
    
    weak var delegate: NotiPopupDelegate?
    
    var notiTitle: String = ""
    var desc: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwContainer.applyCornerRadius(cornerRadius: 10)
        lbTitle.text = notiTitle
        tvDesc.text = desc
        let maxHeight = UIScreen.main.bounds.height*0.5
        if tvDesc.bounds.height > maxHeight {
            tvDesc.isScrollEnabled = true
            tvDesc.heightAnchor.constraint(equalToConstant: maxHeight).isActive = true
        }
    }
    
    @IBAction func dismissHandler(_ sender: Any) {
        delegate?.tapBtn(sourceVC: self)
    }
}
