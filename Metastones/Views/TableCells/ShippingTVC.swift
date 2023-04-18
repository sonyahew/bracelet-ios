//
//  ShippingTVC.swift
//  Metastones
//
//  Created by Sonya Hew on 01/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ShippingTVC: UITableViewCell {
    
    @IBOutlet weak var vwBorder: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var ivService: UIImageView!
    @IBOutlet weak var lbFee: UILabel!
    
    override func awakeFromNib() {
        ivService.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        ivService.layer.borderWidth = 1
        vwBorder.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        vwBorder.layer.borderWidth = 1
    }

    func checkHandler(bool: Bool) {
        btnCheck.isSelected = bool
    }
}
