//
//  FilterTVC.swift
//  Metastones
//
//  Created by Sonya Hew on 05/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class FilterTVC: UITableViewCell {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
    }
    
    func toggleSelected() {
        btnCheck.isSelected = !btnCheck.isSelected
    }
}
