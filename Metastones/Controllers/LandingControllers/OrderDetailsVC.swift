//
//  OrderDetailsVC.swift
//  Metastones
//
//  Created by Sonya Hew on 30/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import Lottie

enum OrderDetailType {
    case orderDetail
    case purchaseDetail
}

class OrderDetailsVC: UIViewController {
    
    let popupManager = PopupManager.shared
    let appData = AppData.shared
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCreate: UILabel!
    @IBOutlet weak var lbSignUp: BrownButton!
    @IBOutlet weak var vwSignup: UIView!
    
    var type: OrderDetailType = .orderDetail
    var data: OrderHistorySubdataModel?
    var itemData: [OrderItemModel?] = []
    var selectedIndex: Int = 0
    var checkoutId: String = ""
    var isAcademy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        lbTitle.text = kLb.order_detail.localized.capitalized
        
        switch data?.transactionType {
        case ProductType.standard.rawValue:
            itemData = data?.items ?? []
            
        case ProductType.custom.rawValue:
            if type == .orderDetail {
                let item = data?.items[selectedIndex]
                itemData.append(item)
                itemData.append(contentsOf: item?.bead ?? [])
                
            } else {
                for item in data?.items ?? [] {
                    itemData.append(item)
                    itemData.append(contentsOf: item?.bead ?? [])
                }
            }
            
        default:
            itemData = []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLoginForFooterDisplay()
    }
    
    func checkLoginForFooterDisplay() {
        if let sessionId = self.appData.data?.sessionId, sessionId != "" {
            vwSignup.isHidden = false
            popupManager.showAlert(destVC: popupManager.getCreateAccPopup(mobile: data?.contact ?? "", email: data?.email ?? "", checkoutId: checkoutId, orderDetailsVC: self, isAcademy: isAcademy))
        } else {
            vwSignup.isHidden = true
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        tableView.sectionFooterHeight = 0.01
        tableView.sectionHeaderHeight = 0.01
    }
    
    @IBAction func backHandler(_ sender: Any) {
        if type == .orderDetail {
            navigationController?.popViewController(animated: true)
            
        } else {
            let vc = getViewControllerFromStackFor(viewController: MenuVC(), currVC: self)
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    @IBAction func signupHandler(_ sender: Any) {
        checkLoginForFooterDisplay()
    }
}

extension OrderDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return type == .orderDetail ? 5 : 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (type == .orderDetail && section == 2) || (type == .purchaseDetail && section == 3) {
            return itemData.count
            
        } else if (type == .orderDetail && section == 0) || (type == .purchaseDetail && section == 1) {
            return (data?.shippingAddr != nil && data?.shippingAddr != "") ? 1 : 0
            
        } else if (type == .orderDetail && section == 1) || (type == .purchaseDetail && section == 2) {
            return (data?.billingAddr != nil && data?.billingAddr != "") ? 1 : 0
            
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .orderDetail {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shippingDetailsTVC") as! ShippingDetailsTVC
                cell.selectionStyle = .none
                cell.lbShipTo.text = kLb.ship_to.localized
                cell.lbName.text = data?.shipAddrName
                cell.lbPhoneNo.text = data?.contact
                cell.lbAddress.text = data?.shippingAddr
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shippingDetailsTVC") as! ShippingDetailsTVC
                cell.selectionStyle = .none
                cell.lbShipTo.text = kLb.bill_to.localized
                cell.lbName.text = data?.billAddrName
                cell.lbPhoneNo.text = data?.contact
                cell.lbAddress.text = data?.billingAddr
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ordersTVC") as! OrdersTVC
                let itemData = self.itemData[indexPath.row]
                cell.ivProduct.loadWithCache(strUrl: itemData?.imgPath)
                cell.title = "\(itemData?.productName ?? "")\n\((itemData?.optionName ?? []).joined(separator: "\n"))"
                cell.price = "\(itemData?.currencyCode ?? "")\(itemData?.unitPrice?.toDisplayCurrency() ?? "")"
                cell.qty = "\(kLb.quantity.localized): \(itemData?.qty ?? 0)"
                cell.item = itemData
                cell.selectionStyle = .none
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailsTVC") as! OrderDetailsTVC
                cell.lbOrderNo.text = data?.orderNo
                cell.lbOrderDate.text = data?.displayDate
                cell.lbPaidDate.text = ""
                cell.btnDelivered.setTitle(data?.statusDesc?.localized, for: .normal)
                cell.selectionStyle = .none
                return cell
                
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "subtotalTVC") as! SubtotalTVC
                cell.lbSubtotal.text = kLb.subtotal.localized
                cell.lbSubtotalValue.text = "\(data?.items.first??.currencyCode ?? "")\(data?.subtotal?.toDisplayCurrency() ?? "")"
                cell.lbShippingFee.text = kLb.shipping.localized
                cell.lbShippingFeeValue.text = "\(data?.items.first??.currencyCode ?? "")\(data?.totalDelivery?.toDisplayCurrency() ?? "")"
                cell.lbDiscount.text = kLb.discount.localized
                cell.lbDiscountValue.text = "-\(data?.items.first??.currencyCode ?? "")\(data?.totalDisc?.toDisplayCurrency() ?? "0.00")"
                cell.lbDiscountValue.textColor = data?.totalDisc == nil || data?.totalDisc == "" || data?.totalDisc == "0.00" ? .black : .red
                cell.lbQty.text = "\(data?.items.count ?? 0) \(kLb.items.localized)"
                cell.lbTotal.attributedText = setupTotal(label: kLb.total.localized, value: "\(data?.items.first??.currencyCode ?? "")\(data?.totalAmount?.toDisplayCurrency() ?? "")")
                cell.lbMetacoin.text = kLb.meta_coins.localized
                cell.lbMetacoinValue.text = "-\(data?.items.first??.currencyCode ?? "")\(data?.payment.filter({ $0?.ewalletTypeCode == eWalletCode.metaCoin.rawValue }).first??.paidAmount ?? "0.00")"
                cell.lbMetapoint.text = kLb.meta_points.localized
                cell.lbMetapointValue.text = "-\(data?.items.first??.currencyCode ?? "")\(data?.payment.filter({ $0?.ewalletTypeCode == eWalletCode.metaPoint.rawValue }).first??.paidAmount ?? "0.00")"
                cell.selectionStyle = .none
                return cell
                
            default:
                return UITableViewCell()
            }
            
        } else {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseStatusTVC") as! PurchaseStatusTVC
                cell.lbCode.text = data?.orderNo ?? ""
                cell.lbDesc.text = data?.displayDate ?? ""
                cell.selectionStyle = .none
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shippingDetailsTVC") as! ShippingDetailsTVC
                cell.selectionStyle = .none
                cell.lbShipTo.text = kLb.ship_to.localized
                cell.lbName.text = data?.shipAddrName
                cell.lbPhoneNo.text = data?.contact
                cell.lbAddress.text = data?.shippingAddr
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "shippingDetailsTVC") as! ShippingDetailsTVC
                cell.selectionStyle = .none
                cell.lbShipTo.text = kLb.bill_to.localized
                cell.lbName.text = data?.billAddrName
                cell.lbPhoneNo.text = data?.contact
                cell.lbAddress.text = data?.billingAddr
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ordersTVC") as! OrdersTVC
                let itemData = self.itemData[indexPath.row]
                cell.ivProduct.loadWithCache(strUrl: itemData?.imgPath)
                cell.title = itemData?.productName ?? ""
                cell.price = "\(itemData?.currencyCode ?? "")\(itemData?.unitPrice ?? "")"
                cell.qty = "\(kLb.quantity.localized): \(itemData?.qty ?? 0)"
                cell.item = itemData
                cell.selectionStyle = .none
                return cell
                
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailsTVC") as! OrderDetailsTVC
                cell.lbOrderNo.text = data?.orderNo
                cell.lbOrderDate.text = data?.displayDate
                cell.lbPaidDate.text = ""
                cell.btnDelivered.setTitle(data?.statusDesc?.localized, for: .normal)
                cell.selectionStyle = .none
                return cell
                
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "subtotalTVC") as! SubtotalTVC
                cell.lbSubtotal.text = kLb.subtotal.localized
                cell.lbSubtotalValue.text = "\(data?.items.first??.currencyCode ?? "")\(data?.subtotal ?? "")"
                cell.lbShippingFee.text = kLb.shipping.localized
                cell.lbShippingFeeValue.text = "\(data?.items.first??.currencyCode ?? "")\(data?.totalDelivery ?? "")"
                cell.lbDiscount.text = kLb.discount.localized
                cell.lbDiscountValue.text = "-\(data?.items.first??.currencyCode ?? "")\(data?.totalDisc ?? "0.00")"
                cell.lbDiscountValue.textColor = data?.totalDisc == nil || data?.totalDisc == "" || data?.totalDisc == "0.00" ? .black : .red
                cell.lbQty.text = "\(data?.items.count ?? 0) \(kLb.items.localized)"
                cell.lbTotal.attributedText = setupTotal(label: kLb.total.localized, value: "\(data?.items.first??.currencyCode ?? "")\(data?.totalAmount ?? "")")
                cell.lbMetacoin.text = kLb.meta_coins.localized
                cell.lbMetacoinValue.text = "-\(data?.items.first??.currencyCode ?? "")\(data?.payment.filter({ $0?.ewalletTypeCode == eWalletCode.metaCoin.rawValue }).first??.paidAmount ?? "0.00")"
                cell.lbMetapoint.text = kLb.meta_points.localized
                cell.lbMetapointValue.text = "-\(data?.items.first??.currencyCode ?? "")\(data?.payment.filter({ $0?.ewalletTypeCode == eWalletCode.metaPoint.rawValue }).first??.paidAmount ?? "0.00")"
                cell.selectionStyle = .none
                return cell
                
            default:
                return UITableViewCell()
            }
        }
        
        //        case 5:
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "giftMessageTVC") as! GiftMessageTVC
        //            cell.selectionStyle = .none
        //            return cell
        //
        //        case 6:
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "submitActionsTVC") as! SubmitActionsTVC
        //            cell.selectionStyle = .none
        //            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (type == .purchaseDetail && indexPath.section == 2) && data?.transactionType == ProductType.custom.rawValue {
            
            let orderDetailsVC = getVC(sb: "Landing", vc: "OrderDetailsVC") as! OrderDetailsVC
            orderDetailsVC.data = data
            orderDetailsVC.selectedIndex = indexPath.row
            navigationController?.pushViewController(orderDetailsVC, animated: true)
        }
    }
}

//MARK:- PurchaseStatusTVC
class PurchaseStatusTVC: UITableViewCell {
    
    @IBOutlet weak var lottieContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCode: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    
    override func awakeFromNib() {
        lbTitle.text = kLb.thank_you_for_your_purchase.localized.capitalized
        
        let lottie = AnimationView(name: "successAnim")
        lottieContainer.addSubviewAndPinEdges(lottie)
        lottie.play()
    }
}

//MARK:- ShippingDetailsTVC
class ShippingDetailsTVC: UITableViewCell {
    
    @IBOutlet weak var lbShipTo: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPhoneNo: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    
}

//MARK:- OrdersTVC
class OrdersTVC: UITableViewCell {
    
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var btnPreview: UIButton!
    @IBOutlet weak var constraintWidthBtnPreview: NSLayoutConstraint!
    
    var item: OrderItemModel? {
        didSet {
            btnPreview.isHidden = item?.bead.count ?? 0 <= 0
            constraintWidthBtnPreview.constant = item?.bead.count ?? 0 <= 0 ? 0 : 50
        }
    }
    
    var imgProduct: UIImage = UIImage() {
        didSet {
            ivProduct.image = imgProduct
        }
    }
    
    var title: String = "" {
        didSet {
            lbTitle.text = title
        }
    }
    
    var price: String = "" {
        didSet {
            lbPrice.text = price
        }
    }
    
    var qty: String = "" {
        didSet {
            lbQty.text = qty
        }
    }
    
    @IBAction func previewHandler(_ sender: Any) {
        let vc = getVC(sb: "Create", vc: "PreviewVC") as! PreviewVC
        vc.orderItem = item
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- OrderDetailsTVC
class OrderDetailsTVC: UITableViewCell {
    
    @IBOutlet weak var lbOrderNo: UILabel!
    @IBOutlet weak var lbOrderDate: UILabel!
    @IBOutlet weak var lbPaidDate: UILabel!
    @IBOutlet weak var btnDelivered: UIButton!
    
    override func awakeFromNib() {
        btnDelivered.applyCornerRadius(cornerRadius: 10)
    }
    
}

//MARK:- SubtotalTVC
class SubtotalTVC: UITableViewCell {
    
    @IBOutlet weak var lbSubtotal: UILabel!
    @IBOutlet weak var lbSubtotalValue: UILabel!
    @IBOutlet weak var lbShippingFee: UILabel!
    @IBOutlet weak var lbShippingFeeValue: UILabel!
    @IBOutlet weak var lbDiscount: UILabel!
    @IBOutlet weak var lbDiscountValue: UILabel!
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbMetacoin: UILabel!
    @IBOutlet weak var lbMetacoinValue: UILabel!
    @IBOutlet weak var lbMetapoint: UILabel!
    @IBOutlet weak var lbMetapointValue: UILabel!
}

//MARK:- GiftMessageTVC
class GiftMessageTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTo: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbMessageValue: UILabel!
    @IBOutlet weak var lbFrom: UILabel!
    
    override func awakeFromNib() {
        lbTitle.text = kLb.your_gift_card_message.localized
        lbTo.attributedText = NSAttributedString(string: "To: Catherine")
        lbMessage.text = kLb.your_message.localized
        lbMessageValue.text = kLb.your_message.localized
        lbFrom.attributedText = NSAttributedString(string: "From: John")
    }
}

//MARK:- SubmitActionsTVC
class SubmitActionsTVC: UITableViewCell {
    
    @IBOutlet weak var btnReturn: ReversedBrownButton!
    @IBOutlet weak var btnWriteReview: BrownButton!
    
}
