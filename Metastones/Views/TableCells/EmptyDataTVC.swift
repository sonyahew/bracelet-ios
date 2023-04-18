//
//  EmptyDataTVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class EmptyDataTVC: UITableViewCell {
    
    @IBOutlet weak var ivBg: UIImageView!
    @IBOutlet weak var lbMsg: UILabel!
    
    var isHistory : Bool = false
    var msg: String? = nil
    
    override func awakeFromNib() {
        selectionStyle = .none
        lbMsg.text = kLb.no_content_at_this_moment.localized
    }
}
