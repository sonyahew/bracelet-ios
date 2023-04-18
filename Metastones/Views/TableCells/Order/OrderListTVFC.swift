//
//  OrderListTVFC.swift
//  Metastones
//
//  Created by Sonya Hew on 24/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class OrderListTVFC: UITableViewHeaderFooterView {

    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lbPrice: UILabel!
    
    var price: String = "" {
        didSet {
            lbPrice.text = price
        }
    }
    
    override func awakeFromNib() {
        btnStatus.applyCornerRadius(cornerRadius: 10)
    }
    
    func setupStatus(key: String) {
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        btnStatus.applyCornerRadius(cornerRadius: 7)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
