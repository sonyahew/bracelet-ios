//
//  FilterTVHC.swift
//  Metastones
//
//  Created by Sonya Hew on 05/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class FilterTVHC: UITableViewHeaderFooterView {
    
    @IBOutlet weak var btnHeader: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbExpansion: UILabel!
    
    weak var delegate: FilterDelegate?
    
    override func awakeFromNib() {
    }
    
    @IBAction func headerTapHandler(_ sender: Any) {
        delegate?.didTapHeader(section: tag)
    }
}
