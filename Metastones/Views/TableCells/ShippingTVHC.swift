//
//  ShippingTVHC.swift
//  Metastones
//
//  Created by Sonya Hew on 01/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ShippingTVHC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var vwBorder: UIView!
    @IBOutlet weak var lbShipping: UILabel!
    @IBOutlet weak var lbFee: UILabel!
    
    override func awakeFromNib() {
        vwBorder.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        vwBorder.layer.borderWidth = 1
        
        lbShipping.text = kLb.shipping.localized
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
