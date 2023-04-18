//
//  CreateCartTVFC.swift
//  Metastones
//
//  Created by Sonya Hew on 31/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class CreateCartTVFC: UITableViewHeaderFooterView {
    
    var tableView = UITableView()
    
    @IBOutlet weak var lbMsgTitle: UILabel!
    @IBOutlet weak var lbMsgDesc: UILabel!
    @IBOutlet weak var svMessage: UIStackView!
    @IBOutlet weak var lbExpansion: UILabel!
    
    @IBOutlet weak var tfReceiverName: UITextField!
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var tfUserName: UITextField!
    
    var isMsgHidden = true
    
    override func awakeFromNib() {
        svMessage.subviews[0].isHidden = true
        
        for tf in [tfReceiverName, tfMessage, tfUserName] {
            tf?.layer.borderColor = UIColor(hex: 0xBCBCBC).cgColor
            tf?.layer.borderWidth = 1
            tf?.applyCornerRadius(cornerRadius: 4)
            tf?.setLeftPaddingPoints(16)
            tf?.setRightPaddingPoints(16)
            tf?.attributedPlaceholder = NSAttributedString(string: "Field", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xC7C7C7)])
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func msgToggleHandler(_ sender: Any) {
           if isMsgHidden {
               UIView.animate(withDuration: 0.3) {
                   self.svMessage.subviews[0].isHidden = false
               }
               lbExpansion.text = "-"
           } else {
               UIView.animate(withDuration: 0.3) {
                   self.svMessage.subviews[0].isHidden = true
               }
               lbExpansion.text = "+"
           }
           isMsgHidden = !isMsgHidden
           tableView.beginUpdates()
           tableView.endUpdates()
       }
}
