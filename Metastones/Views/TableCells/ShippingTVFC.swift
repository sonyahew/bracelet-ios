//
//  ShippingTVFC.swift
//  Metastones
//
//  Created by Sonya Hew on 01/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ShippingTVFC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var vwBorder: UIView!
    
    override func awakeFromNib() {
        vwBorder.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        vwBorder.layer.borderWidth = 1
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
