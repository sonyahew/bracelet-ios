//
//  AddToCartPopupVC.swift
//  Metastones
//
//  Created by Sonya Hew on 23/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum AddToCartPopupAction {
    case viewCart
    case continueShop
}

class AddToCartPopupVC: UIViewController {

    @IBOutlet weak var ivProduct: UIImageView!
    
    @IBOutlet weak var btnViewCart: ReversedBrownButton!
    @IBOutlet weak var btnContinue: BrownButton!
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var imgUrl : String? = ""
    var prdName : String? = ""
    var prdQty : String? = ""
    var prdCurrCode : String? = ""
    var prdPrice : String? = ""
    var prdSizes: [String]? = []
    
    var action: AddToCartPopupAction = .continueShop
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.items_added_to_shopping_cart.localized
        
        btnViewCart.setTitle(kLb.view_cart.localized, for: .normal)
        btnContinue.setTitle(kLb._continue.localized, for: .normal)
        
        ivProduct.loadWithCache(strUrl: imgUrl)
        lbProductName.text = prdName
        
        let qty = UILabel()
        qty.font = .systemFont(ofSize: 14)
        qty.textColor = #colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1)
        qty.text = "\(kLb.quantity.localized)  \(prdQty ?? "") x \(prdCurrCode ?? "")\(prdPrice ?? "")"
        qty.heightAnchor.constraint(equalToConstant: 44).isActive = true
        qty.minimumScaleFactor = 0.5
        
        for subview in stackView.subviews {
            subview.removeFromSuperview()
        }
    
        stackView.addArrangedSubview(qty)
        
        for prdSize in prdSizes ?? [] {
            let size = UILabel()
            size.font = .systemFont(ofSize: 14)
            size.textColor = #colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1)
            size.text = prdSize
            size.heightAnchor.constraint(equalToConstant: 32).isActive = true
            size.minimumScaleFactor = 0.5
            stackView.addArrangedSubview(size)
        }
    }
    
    @IBAction func viewCartHandler(_ sender: Any) {
        action = .viewCart
        self.sheetViewController?.dismiss(animated: true)
    }
    
    @IBAction func continueHandler(_ sender: Any) {
        action = .continueShop
        self.sheetViewController?.dismiss(animated: true)
    }
}
