//
//  ListingCVC.swift
//  Metastones
//
//  Created by Sonya Hew on 23/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol ListingCVCDelegate: class {
    func updateWishlist(index: Int)
}

class ListingCVC: UICollectionViewCell {
    
    //best seller banner
    @IBOutlet weak var vwBestSeller: UIView!
    @IBOutlet weak var lbBestSeller: UILabel!
    
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var btnFav: UIButton!
    
    weak var delegate: ListingCVCDelegate?
    
    var imgProduct: UIImage = UIImage() {
        didSet {
            ivProduct.image = imgProduct
        }
    }
    
    var price: String = "" {
        didSet {
            lbPrice.text = price
        }
    }
    
    var desc: String = "" {
        didSet {
            lbDesc.text = desc
        }
    }
    
    var isFav: Bool = false {
        didSet {
            btnFav.setImage(isFav ? #imageLiteral(resourceName: "icon-fav-on") : #imageLiteral(resourceName: "icon-fav-off"), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        lbBestSeller.text = kLb.best_seller.localized
    }
    
    @IBAction func favHandler(_ sender: Any) {
        if isMemberUser(vc: UIApplication.topViewController()?.navigationController) {
            delegate?.updateWishlist(index: self.tag)
        }
    }
    
    func setupFlag(isShow: Bool) {
        
    }
}
