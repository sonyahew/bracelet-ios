//
//  EmptyDataCVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class EmptyDataCVC: UICollectionViewCell {
    
    @IBOutlet weak var ivBg: UIImageView!
    @IBOutlet weak var lbMsg: UILabel!
    
    var msg: String? = nil
    
    override func awakeFromNib() {
        lbMsg.text = kLb.no_content_at_this_moment.localized
    }
}
