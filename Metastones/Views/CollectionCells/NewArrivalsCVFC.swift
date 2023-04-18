//
//  NewArrivalsCVFC.swift
//  Metastones
//
//  Created by Sonya Hew on 23/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum NewArrivalsCellPosition {
    case first
    case last
}

class NewArrivalsCVFC: UICollectionViewCell {
    
    //first cell
    @IBOutlet weak var vwFirstCell: UIView!
    @IBOutlet weak var lbHeading: UILabel!
    @IBOutlet weak var lbTitle: UILabel!

    //last cell
    @IBOutlet weak var vwLastCell: UIView!
    @IBOutlet weak var lbViewAll: UILabel!
    
    var heading: String = "" {
        didSet {
            lbHeading.text = heading
        }
    }
    
    var title: String = "" {
        didSet {
            lbTitle.text = title
        }
    }
    
    override func awakeFromNib() {
        vwFirstCell.isHidden = true
        vwLastCell.isHidden = true
        
        if isSmallScreen {
            lbTitle.font = .systemFont(ofSize: 32, weight: .light)
        }
        
        lbViewAll.text = kLb.view_all.localized
        lbTitle.text = kLb.new_arrivals.localized.uppercased()
        lbHeading.text = kLb.new_items.localized.uppercased()
    }
    
    func setupAs(position: NewArrivalsCellPosition) {
        if position == .first {
            vwFirstCell.isHidden = false
            vwLastCell.isHidden = true
        } else {
            vwFirstCell.isHidden = true
            vwLastCell.isHidden = false
        }
    }
}
