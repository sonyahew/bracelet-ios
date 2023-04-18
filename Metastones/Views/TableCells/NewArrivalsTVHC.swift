//
//  NewArrivalsTVHC.swift
//  Metastones
//
//  Created by Sonya Hew on 13/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class NewArrivalsTVHC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbViewMore: UILabel!
    
    weak var tabDelegate: SwitchTabDelegate?
    
    override func awakeFromNib() {
        lbViewMore.text = kLb.view_more.localized
    }
    
    @IBAction func viewmoreHandler(_ sender: Any) {
        tabDelegate?.switchTab(to: 1)
    }
}
