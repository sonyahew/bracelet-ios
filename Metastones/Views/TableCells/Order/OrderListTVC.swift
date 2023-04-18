
//
//  OrderListTVC.swift
//  Metastones
//
//  Created by Sonya Hew on 24/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class OrderListTVC: UITableViewCell {
    
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbQty: UILabel!
    
    var imgProduct: UIImage = UIImage() {
        didSet {
            ivProduct.image = imgProduct
        }
    }
    
    var title: String = "" {
        didSet {
            lbTitle.text = title
        }
    }
    
    var price: String = "" {
        didSet {
            lbPrice.text = price
        }
    }
    
    var qty: String = "" {
        didSet {
            lbQty.text = qty
        }
    }
}
