//
//  NewArrivalsCVC.swift
//  Metastones
//
//  Created by Sonya Hew on 22/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class NewArrivalsCVC: UICollectionViewCell {
    
    @IBOutlet weak var vwProduct: UIView!
    @IBOutlet weak var ivProduct: UIImageView!
    
    var data: ProductDataModel?
    
    var imgProduct: UIImage = UIImage() {
        didSet {
            ivProduct.image = imgProduct
        }
    }
    
    override func awakeFromNib() {
        ivProduct.contentMode = .scaleAspectFill
        vwProduct.applyCornerRadius(cornerRadius: 12)
        addShadow(withRadius: 3, opacity: 0.16, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 3))
    }
}
