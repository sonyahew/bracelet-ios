//
//  VouchersVC.swift
//  Metastones
//
//  Created by Sonya Hew on 02/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum DiscountType: String {
    case percent = "percent"
    case cash = "cash"
}

class VouchersVC: UIViewController {

    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var vouchers: [CheckoutVoucherModel?] = []
    var selectedVoucherCode: String?
    var noData : Bool = true
    var popup = PopupManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.vouchers.localized
        setupTableView()
        
        noData = vouchers.count == 0
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
    }
    
    @IBAction func dismissHandler(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension VouchersVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : vouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            cell.lbMsg.text = kLb.no_vouchers_available.localized
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "voucherTVC") as! VoucherTVC
        let data = vouchers[indexPath.row]
        cell.selectionStyle = .none
        
        let isPercentDisc = data?.discountType ?? "" == DiscountType.percent.rawValue
        
        cell.lbCurrency.text =  isPercentDisc ? "" : data?.currencyCode
        cell.lbValue.text = isPercentDisc ? "\(data?.percentDisc ?? 0)%" : data?.amountDisc
        cell.lbVoucherName.text = "\(kLb.min_spend.localized) \(data?.currencyCode ?? "") \(data?.minSpend ?? "")"
        let discount = isPercentDisc ? "\(data?.percentDisc ?? 0)%" : "\(data?.currencyCode ?? "") \(data?.amountDisc ?? "")"
        cell.lbDesc.text = "\(kLb.for_every_purchase_get.localized) \(discount) \(kLb.discount.localized)"
        cell.lbValidity.text = "\(kLb.valid_till.localized) \(data?.endDate ?? "")"
        if data?.voucherCode == selectedVoucherCode {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            selectedVoucherCode = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let validity = vouchers[indexPath.row]?.validity
        switch validity {
            case "A":
                let deliveryAddrVC = getViewControllerFromStackFor(viewController: DeliveryVC(), currVC: self) as! DeliveryVC
                deliveryAddrVC.selectedVoucher = vouchers[indexPath.row]
                self.navigationController?.popToViewController(deliveryAddrVC, animated: true)
            
            case "NE":
                popup.showAlert(destVC: popup.getAlertPopup(title: kLb.not_eligible_to_use_voucher.localized, desc: ""))
            
            default:
                popup.showAlert(destVC: popup.getAlertPopup(title: "\(kLb.please_spend_above.localized) \(vouchers[indexPath.row]?.currencyCode ?? "")\(vouchers[indexPath.row]?.minSpend ?? "")", desc: ""))
        }
    }
}

//MARK:- VoucherTVC
class VoucherTVC: UITableViewCell {
    
    @IBOutlet weak var lbCurrency: UILabel!
    @IBOutlet weak var lbValue: UILabel!
    @IBOutlet weak var lbDiscount: UILabel!
    
    @IBOutlet weak var lbVoucherName: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var lbValidity: UILabel!
    
    override func awakeFromNib() {
        lbDiscount.text = kLb.discount.localized
    }
}
