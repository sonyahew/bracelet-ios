//
//  OrderListTVHC.swift
//  Metastones
//
//  Created by Sonya Hew on 24/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class OrderListTVHC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lbOrderNo: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbOrderDate: UILabel!
    @IBOutlet weak var lbPaidDate: UILabel!
    
    var orderNo: String = "" {
        didSet {
            lbOrderNo.text = orderNo
        }
    }
    
    var status: String = "" {
        didSet {
            lbStatus.text = status
        }
    }
    
    var orderDate: String = "" {
        didSet {
            lbOrderDate.text = orderDate
        }
    }
    
    var paidDate: String = "" {
        didSet {
            lbPaidDate.text = paidDate
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
