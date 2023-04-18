//
//  CreateCartTVC.swift
//  Metastones
//
//  Created by Sonya Hew on 31/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class CreateCartTVC: UITableViewCell {
    
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lbProduct: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var vwSeparator: UIView!
    
    var data: CartItemModel?
    
    override func awakeFromNib() {
        ivProduct.loadWithCache(strUrl: data?.imgPath)
        lbProduct.text = "\(data?.productName ?? "")\n\(data?.optionName?.joined(separator: "\n") ?? "")"
        lbAmount.text = "\(data?.currencyCode ?? "")\(data?.unitPrice ?? "")"
        lbQuantity.text = "\(kLb.quantity.localized): \(data?.qty ?? 1)"
    }
}
