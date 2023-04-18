//
//  MenuTVHC.swift
//  Metastones
//
//  Created by Sonya Hew on 12/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class MenuTVHC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    weak var delegate: FilterDelegate?
    
    override func awakeFromNib() {
    }
    
    @IBAction func headerTapHandler(_ sender: Any) {
        delegate?.didTapHeader(section: tag)
    }
}
