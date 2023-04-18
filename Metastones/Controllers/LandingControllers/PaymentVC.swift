//
//  PaymentVC.swift
//  Metastones
//
//  Created by Sonya Hew on 04/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    
    //topTabs
    @IBOutlet weak var lbCard: UILabel!
    @IBOutlet weak var lbBanking: UILabel!
    @IBOutlet weak var ivCard: UIImageView!
    @IBOutlet weak var ivOnlineBanking: UIImageView!
    @IBOutlet weak var btnCard: UIButton!
    @IBOutlet weak var btnBanking: UIButton!
    
    //footer
    @IBOutlet weak var vwBottom: UIView!
    @IBOutlet weak var lbSubtotal: UILabel!
    @IBOutlet weak var lbSubtotalValue: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbTotalValue: UILabel!
    
    let titles = ["Maybank", "Hong Leong Bank", "Public Bank", "RHB Bank", "AmBank", "CIMB Bank"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFooter()
        
        lbTitle.text = kLb.payment_gateway.localized.capitalized
        lbCard.text = kLb.debit_credit_card.localized
        lbBanking.text = kLb.online_banking.localized
        
        lbSubtotal.text = kLb.subtotal.localized
        lbTotal.text = kLb.total.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
    }
    
    func setupFooter() {
        vwBottom.addShadow(withRadius: 6, opacity: 0.1, color: UIColor.black.cgColor, offset: CGSize(width: 3, height: 0))
    }
    
    @IBAction func cardHandler(_ sender: Any) {
        lbCard.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        ivCard.image = #imageLiteral(resourceName: "icon-payment-card-on.png")
        
        lbBanking.textColor = #colorLiteral(red: 0.6156862745, green: 0.6156862745, blue: 0.6156862745, alpha: 1)
        ivOnlineBanking.image = #imageLiteral(resourceName: "icon-payment-bank-off.png")
    }
    
    @IBAction func bankingHandler(_ sender: Any) {
        lbBanking.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        ivOnlineBanking.image = #imageLiteral(resourceName: "icon-payment-bank-on")
        
        lbCard.textColor = #colorLiteral(red: 0.6156862745, green: 0.6156862745, blue: 0.6156862745, alpha: 1)
        ivCard.image = #imageLiteral(resourceName: "icon-payment-card-off")
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension PaymentVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentTVC", for: indexPath) as! PaymentTVC
        cell.selectionStyle = .none
        cell.lbBankName.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PaymentTVC
        cell.setTo(isSelected: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PaymentTVC
        cell.setTo(isSelected: false)
    }
}

//MARK:- PaymentTVC
class PaymentTVC: UITableViewCell {
    
    @IBOutlet weak var vwBank: UIView!
    @IBOutlet weak var ivBank: UIImageView!
    @IBOutlet weak var lbBankName: UILabel!
    @IBOutlet weak var ivCheck: UIImageView!
    
    override func awakeFromNib() {
        vwBank.applyCornerRadius(cornerRadius: 5)
        vwBank.layer.borderColor = UIColor(hex: 0xE3E3E3).cgColor
        vwBank.layer.borderWidth = 1
        setTo(isSelected: false)
    }
    
    func setTo(isSelected: Bool) {
        if isSelected {
            vwBank.layer.borderColor = UIColor(hex: 0x00C73D).cgColor
            ivCheck.isHidden = false
        } else {
            vwBank.layer.borderColor = UIColor(hex: 0xE3E3E3).cgColor
            ivCheck.isHidden = true
        }
    }
}
