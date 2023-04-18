//
//  CreateCartTVHC.swift
//  Metastones
//
//  Created by Sonya Hew on 31/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class CreateCartTVHC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbCreate: UILabel!
    
    let cartViewModel = CartViewModel()
    var data: CartItemModel?
    
    weak var delegate: CartTVCDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        lbCreate.text = kLb.create_own_design.localized
    }
    
    @IBAction func checkHandler(_ sender: Any) {
        let btn = sender as! UIButton
        if let prdCartId = data?.prdCartId, let prdType = data?.prdType {
            cartViewModel.addCart(prdCartId: "\(prdCartId)", checked: !btn.isSelected ? "1" : "0", prdType: prdType, groupId: data?.groupId) { (proceed, data) in
                if proceed {
                    self.delegate?.updateCartList(cartList: data)
                    btn.isSelected = !btn.isSelected
                }
            }
        }
    }
}
