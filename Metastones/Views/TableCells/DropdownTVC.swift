//
//  DropdownTVC.swift
//  Metastones
//
//  Created by Sonya Hew on 20/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class DropdownTVC: UITableViewCell {

    @IBOutlet weak var ivLeft: UIImageView!
    @IBOutlet weak var lbText: UILabel!
    
    var strImage: String?
    var strText: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let strImage = strImage {
            ivLeft.isHidden = false
            ivLeft.loadWithCache(strUrl: strImage)
        } else {
            ivLeft.isHidden = true
        }
        
        lbText.text = strText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
