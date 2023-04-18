//
//  ContactUsVC.swift
//  Metastones
//
//  Created by Sonya Hew on 07/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ContactUsVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionFooterHeight = 0.01
        tableView.sectionHeaderHeight = 0.01
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ContactUsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapTVC") as! MapTVC
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "enquiryTVC") as! EnquiryTVC
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}

//MARK:- MapTVC
class MapTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCompanyName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbAddressValue: UILabel!
    @IBOutlet weak var lbContactNo: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var btnGetDirection: BrownButton!
    
    override func awakeFromNib() {
        
    }
    
    @IBAction func getDirectionHandler(_ sender: Any) {
    }
}


//MARK:- EnquiryTVC
class EnquiryTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfRegard: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var btnSend: BrownButton!
    
    let titles = [kLb.name.localized, kLb.email.localized, kLb.mobile.localized]
    let placeholders = [kLb.enter_your_full_name.localized, kLb.enter_your_email.localized, kLb.enter_mobile_number.localized]
    
    override func awakeFromNib() {
        tfRegard.setupTextField(placeholder: "", textColor: .msBrown, placeholderColor: UIColor(hex: 0x7C7C7C), titleLeft: "MR", imgRight: #imageLiteral(resourceName: "icon-chev-down.png"), cornerRadius: 24)

        for (index, tf) in [tfEmail, tfName, tfMobile].enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], textColor: .msBrown, placeholderColor: UIColor(hex: 0x7C7C7C), titleLeft: titles[index], cornerRadius: 24)
        }

        tvMessage.contentInset = UIEdgeInsets(top: 32, left: 14, bottom: 16, right: 16)
        tvMessage.applyCornerRadius(cornerRadius: 24)
        tvMessage.layer.borderWidth = 1
        tvMessage.layer.borderColor = UIColor.msBrown.cgColor
    }
    
    @IBAction func sendHandler(_ sender: Any) {
    }
}
