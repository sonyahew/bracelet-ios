//
//  DeliveryVC.swift
//  Metastones
//
//  Created by Sonya Hew on 01/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum OrderStatusCode: String {
    case success = "00"
    case failed = "01"
    case pending = "02"
}

class DeliveryVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var vwBottom: UIView!
    
    @IBOutlet weak var lbShipping: UILabel!
    @IBOutlet weak var lbSubtotal: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var btnPlaceOrder: UIButton!
    
    let cartViewModel = CartViewModel()
    let appData = AppData.shared
    let popupManager = PopupManager.shared
    
    var prdId: Int?
    var prdType: String?
    var isAcademy: Bool = false
    var isSelfPickup = true
    var isShipping = false
    var isInvalidShipAddr = false
    var courierArr = [Bool](repeating: false, count: 3)
    var checkoutModel : CheckoutDataModel?
    var shippingCourier : [CheckoutShippingModel] = []
    var guestData : ProfileAddrModel?
    var shippingData : ProfileAddrModel?
    var billingData : ProfileAddrModel?
    var fixedPayAmount: Double?
    var payAmount: Double? {
        didSet {
            let strPayAmt = "\(payAmount ?? 0.0)"
            lbTotal.attributedText = setupTotal(label: kLb.pay_amount.localized, value: "\(checkoutModel?.cart?.currencyCode ?? "")\(strPayAmt.toDisplayCurrency())")
        }
    }
    var shippingFee: String?
    var checkoutId: String?
    var metaPointData: CheckoutEwalletModel?
    var metaCoinData: CheckoutEwalletModel?
    var isCheckOrderStatus: Bool = false
    var selectedVoucher: CheckoutVoucherModel? = nil
    var selectedCourier: CheckoutShippingModel? = nil
    
    var metapointTfValue: String?
    var metacoinTfValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFooter()
        
        lbTitle.text = kLb.delivery_address.localized.capitalized
        btnPlaceOrder.setTitle(kLb.place_order.localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    func setupData() {
        if isCheckOrderStatus {
            isCheckOrderStatus = !isCheckOrderStatus
            getOrderStatus(checkoutId: checkoutId)
            
        } else {
            shippingFee = "0.00"
            isInvalidShipAddr = false
            isAcademy = prdType == ProductType.academy.rawValue
            cartViewModel.checkout (prdId: prdId, prdType: prdType) { (proceed, data) in
                if proceed {
                    self.checkoutModel = data?.data
                    self.shippingData = data?.data?.defaultShipping.first ?? nil
                    self.billingData = data?.data?.defaultBilling.first ?? nil
                    self.shippingCourier = data?.data?.shippingFee ?? []
                    self.payAmount = (Double(self.checkoutModel?.cart?.totalAmount ?? "") ?? 0.0)
                    self.setupView()
                }
                if data?.err == 98 {
                    self.isInvalidShipAddr = true
                }
            }
        }
    }
    
    func setupView() {
        metaPointData = checkoutModel?.ewallet.filter({ $0?.ewalletTypeCode == eWalletCode.metaPoint.rawValue }).first ?? nil
        metaCoinData = checkoutModel?.ewallet.filter({ $0?.ewalletTypeCode == eWalletCode.metaCoin.rawValue }).first ?? nil
        
        setupShippingFee()
        
        tableView.reloadData()
    }
    
    func setupShippingFee() {
        payAmount = Double(self.checkoutModel?.cart?.totalAmount ?? "")
        
        if checkoutModel?.freeShipping ?? 0 != 1, let finalPayAmt = payAmount {
            payAmount = finalPayAmt + (Double(self.shippingFee ?? "") ?? 0.0)
        }
        fixedPayAmount = self.payAmount
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ShippingTVC", bundle: Bundle.main), forCellReuseIdentifier: "shippingTVC")
        tableView.register(UINib(nibName: "ShippingTVHC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "shippingTVHC")
        tableView.register(UINib(nibName: "ShippingTVFC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "shippingTVFC")
    }
    
    func setupFooter() {
        
        btnPlaceOrder.applyCornerRadius(cornerRadius: btnPlaceOrder.bounds.height/2)
        //btnPlaceOrder.addShadow(withRadius: 15, opacity: 0.3, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 6))
        
        vwBottom.addShadow(withRadius: 6, opacity: 0.1, color: UIColor.black.cgColor, offset: CGSize(width: 3, height: 0))
    }

    
    @IBAction func placeOrderHandler(_ sender: Any) {
        if isInvalidShipAddr {
            popupManager.showAlert(destVC: popupManager.getErrorPopup(desc: kLb.shipping_address_is_invalid.localized))
            
        } else if (appData.isLoggedIn && !isAcademy && (checkoutModel?.defaultShipping.count == 0 && checkoutModel?.defaultBilling.count == 0)) ||  (!appData.isLoggedIn && !isAcademy && guestData?.address == nil){
            popupManager.showAlert(destVC: popupManager.getErrorPopup(desc: kLb.please_add_an_address.localized))
            
        } else {
            if let arrEwallet = checkoutModel?.ewallet {
                var arrEwalletTypeId: [Int?] = []
                
                arrEwalletTypeId.append(contentsOf: arrEwallet.filter({ $0?.ewalletTypeCode == eWalletCode.metaCoin.rawValue }).map({ $0?.ewalletTypeId }))
                arrEwalletTypeId.append(contentsOf: arrEwallet.filter({ $0?.ewalletTypeCode == eWalletCode.metaPoint.rawValue }).map({ $0?.ewalletTypeId }))
                
                if selectedCourier != nil || shippingCourier.count == 0 {
                    cartViewModel.getPaymentPage(ewalletTypeId: arrEwalletTypeId, payAmount: [metacoinTfValue?.currencyWithoutGrouping() ?? "", metapointTfValue?.currencyWithoutGrouping() ?? ""], totalAmount: checkoutModel?.cart?.totalAmount, courier: selectedCourier, shippingAddrId: checkoutModel?.defaultShipping.first??.id, billingAddrId: checkoutModel?.defaultBilling.first??.id, voucherCode: selectedVoucher?.voucherCode, totalDisc: checkoutModel?.freeShipping ?? 0 == 1 ? shippingFee : "", prdId: prdId, prdType: prdType) { (proceed, data) in
                        if proceed {
                            if let url = data?.data?.url, url != "" {
                                self.checkoutId = data?.data?.checkoutId
                                let paymentGatewayVC = getVC(sb: "Landing", vc: "PaymentGatewayVC") as! PaymentGatewayVC
                                paymentGatewayVC.paymentData = data?.data
                                self.navigationController?.pushViewController(paymentGatewayVC, animated: true)
                                
                            } else {
                                self.getOrderStatus(checkoutId: data?.data?.checkoutId)
                            }
                        }
                    }
                    
                } else {
                    popupManager.showAlert(destVC: popupManager.getErrorPopup(desc: kLb.please_choose_a_courier_method.localized))
                }
            }
        }
        //navigationController?.pushViewController(getVC(sb: "Landing", vc: "PaymentVC"), animated: true)
    }
    
    func calculateShipping() {
        if !isAcademy {
            cartViewModel.calculateShipping() { (proceed, data) in
                if proceed {
                    self.shippingCourier = data?.data?.shipping ?? []
                    self.setupView()
                }
                if data?.err == 98 {
                    self.isInvalidShipAddr = true
                }
            }
        }
    }
    
    func getOrderStatus(checkoutId: String?) {
        cartViewModel.getOrderStatus(checkoutId: checkoutId, prdType: prdType) { (proceed, data) in
             if proceed {
                 switch data?.data?.status {
                     case OrderStatusCode.success.rawValue:
                        if let orderDetail = data?.data?.order.first {
                            let vc = getVC(sb: "Landing", vc: "OrderDetailsVC") as! OrderDetailsVC
                            vc.type = .purchaseDetail
                            vc.data = orderDetail
                            vc.checkoutId = checkoutId ?? ""
                            if self.prdType == ProductType.academy.rawValue {
                                vc.isAcademy = true
                            }
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    
                     case OrderStatusCode.failed.rawValue:
                         self.popupManager.showAlert(destVC: self.popupManager.getAlertPopup(desc: kLb.your_order_is_failed.localized))
                     
                     case OrderStatusCode.pending.rawValue:
                         self.popupManager.showAlert(destVC: self.popupManager.getAlertPopup(desc: kLb.your_order_is_pending.localized))
                     
                     default:
                         return
                 }
             }
         }
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension DeliveryVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return (isAcademy && appData.isLoggedIn) ? 0 : 1
            
        } else if section == 2 {
            return shippingCourier.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "shippingTVHC") as! ShippingTVHC
        if section == 2 {
            header.lbFee.text = "\(checkoutModel?.cart?.currencyCode ?? "")\(shippingFee?.toDisplayCurrency() ?? "0.00")"
            return header
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return shippingCourier.count > 0 ? 48 : 0.01
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickupTVC", for: indexPath) as! PickupTVC
            cell.checkHandler(bool: isSelfPickup)
            cell.selectionStyle = .none
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "shipBillTVC", for: indexPath) as! ShipBillTVC
            let data = appData.isLoggedIn ? shippingData : guestData
            
            cell.lbName.text = data?.displayAddrName ?? "-"
            cell.lbDeliveryAddr.text = data?.address ?? "-"
            cell.lbPhoneNo.text = data?.contactDesc ?? "-"
            cell.lbBillingAddr.text = billingData?.address ?? "-"
            cell.lbEmail.text = billingData?.email ?? "-"
            cell.checkHandler(bool: true)
            //cell.checkHandler(bool: isShipping)
            cell.btnEdit.setTitle( data?.address == nil || data?.address == "" ? kLb.add.localized : kLb.edit.localized, for: .normal)
            //cell.btnCalculateShipping.isHidden = appData.isLoggedIn || isAcademy
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "shippingTVC", for: indexPath) as! ShippingTVC
            var data = shippingCourier[indexPath.row]
            if data.courierId == selectedCourier?.courierId {
                data.selected = true
                shippingFee = data.shipmentPrice ?? ""
                self.setupShippingFee()
            }
            cell.checkHandler(bool: data.selected)
            cell.ivService.loadWithCache(strUrl: data.logo)
            cell.lbFee.text = "\(checkoutModel?.cart?.currencyCode ?? "")\(data.shipmentPrice ?? "")"
            cell.selectionStyle = .none
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "walletVoucherTVC", for: indexPath) as! WalletVoucherTVC
            cell.metaCoinData = metaCoinData
            cell.metaPointData = metaPointData
            cell.selectedVoucher = selectedVoucher
            cell.metapointTfValue = metapointTfValue
            cell.metacoinTfValue = metacoinTfValue
            cell.totalAmount = Double(self.checkoutModel?.cart?.totalAmount ?? "")
            cell.fixedPayAmount = fixedPayAmount
            cell.payAmount = payAmount
            cell.awakeFromNib()
            cell.delegate = self
            cell.textFieldDidChange(cell.tfPoints)
            cell.selectionStyle = .none
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderSummaryTVC", for: indexPath) as! OrderSummaryTVC
            cell.lbSubtotalValue.text = "\(checkoutModel?.cart?.currencyCode ?? "")\(checkoutModel?.cart?.totalAmount?.toDisplayCurrency() ?? "0.00")"
            cell.lbShippingFeeValue.text = "\(self.checkoutModel?.cart?.currencyCode ?? "")\(self.shippingFee?.toDisplayCurrency() ?? "0.00")"
            cell.lbMetaCoinValue.text = "-\(self.checkoutModel?.cart?.currencyCode ?? "")\(metacoinTfValue ?? "0.00")"
            
            let doubleMetapointsTfAmt = Double(metapointTfValue?.currencyWithoutGrouping() ?? "") ?? 0.00
            let doubleTotalMetapointsAmt = doubleMetapointsTfAmt/Double(metaPointData?.unit ?? 1)
            let strTotalMetapointsAmt = "\(doubleTotalMetapointsAmt)".toDisplayCurrency()
            cell.lbMetaPointValue.text = "-\(self.checkoutModel?.cart?.currencyCode ?? "")\(strTotalMetapointsAmt)"
            
            cell.lbMessage.text = checkoutModel?.message
            
            var amountDisc: Double = 0.0
            if self.selectedVoucher?.discountType == DiscountType.percent.rawValue {
                amountDisc = ((Double(self.checkoutModel?.cart?.totalAmount ?? "") ?? 0.0) * Double(self.selectedVoucher?.percentDisc ?? 0)) / 100.0
            } else {
                amountDisc = Double(self.selectedVoucher?.amountDisc ?? "") ?? 0.0
            }
            
            var totalDiscValue: Double = amountDisc
            if checkoutModel?.freeShipping ?? 0 == 1 {
                totalDiscValue += (Double(self.shippingFee ?? "0.00") ?? 0.0)
            }
            cell.lbTotalDiscValue.text = "-\(self.checkoutModel?.cart?.currencyCode ?? "")\("\(totalDiscValue)".toDisplayCurrency() )"
            
            cell.stackView.arrangedSubviews[4].isHidden = checkoutModel?.message == nil || checkoutModel?.message == ""
            
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 0
        } else if indexPath.section == 3 {
            if !appData.isLoggedIn {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            isSelfPickup = true
            isShipping = false
            courierArr = [Bool](repeating: false, count: 3)
        case 1:
            if !isShipping {
                isSelfPickup = false
                isShipping = true
                courierArr = [Bool](repeating: false, count: 3)
                courierArr[0] = true
            }
        case 2:
            isSelfPickup = false
            isShipping = true
            for (index, item) in shippingCourier.enumerated() {
                self.shippingCourier[index].selected = index == indexPath.row
                if index == indexPath.row {
                    self.selectedCourier = item
                    self.shippingFee = item.shipmentPrice ?? ""
                    self.setupShippingFee()
                }
            }
        default:
            print("Error")
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "shippingTVFC") as! ShippingTVFC
        if section == 2 {
            return footer
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return (isAcademy && appData.isLoggedIn) ? 0.01 : 28
        } else {
            return 0.01
        }
    }
}

extension DeliveryVC: ShipBillTVCDelegate {
    func tapEdit() {
        if appData.isLoggedIn {
            let addressListVC = getVC(sb: "Profile", vc: "MyAddressesVC") as! MyAddressesVC
            addressListVC.addressType = .shipping
            addressListVC.addressListType = .select
            UIApplication.topViewController()?.navigationController?.pushViewController(addressListVC, animated: true)
            
        } else {
            let guestDetailsVC = getVC(sb: "Profile", vc: "GuestDetailsVC") as! GuestDetailsVC
            guestDetailsVC.type = isAcademy ? .details : .address
            guestDetailsVC.addrModel = guestData
            guestDetailsVC.parentVC = self
            UIApplication.topViewController()?.navigationController?.pushViewController(guestDetailsVC, animated: true)
        }
    }
}

extension DeliveryVC: WalletVoucherTVCDelegate {
    func updateTf1Value(value: String?) {
        metacoinTfValue = value
    }
    
    func updateTf2Value(value: String?) {
        metapointTfValue = value
    }
    
    func updatePayAmount(payAmount: Double?) {
        self.payAmount = payAmount
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet.init(integer: 4), with: .none)
        }
    }
    
    func info1Tap() {
        popupManager.showAlert(destVC: popupManager.getTitleMsgOnlyPopup(title: metaCoinData?.ewalletTypeName, desc: metaCoinData?.ewalletTypeDesc?.replacingOccurrences(of: "<br>", with: ""), btnTitle: kLb.close.localized))
    }
    
    func info2Tap() {
        popupManager.showAlert(destVC: popupManager.getTitleMsgOnlyPopup(title: metaPointData?.ewalletTypeName, desc: metaPointData?.ewalletTypeDesc?.replacingOccurrences(of: "<br>", with: ""), btnTitle: kLb.close.localized))
    }
    
    func voucherTap() {
        if let vouchers = checkoutModel?.voucher {
            let voucherVC = getVC(sb: "Landing", vc: "VouchersVC") as! VouchersVC
            voucherVC.vouchers = vouchers
            voucherVC.selectedVoucherCode = selectedVoucher?.voucherCode
            self.navigationController?.pushViewController(voucherVC, animated: true)
        }
    }
}

//MARK:- PickupTVC
class PickupTVC: UITableViewCell {
    
    @IBOutlet weak var vwBorder: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbPickup: UILabel!
    @IBOutlet weak var lbArea: UILabel!
    
    override func awakeFromNib() {
        vwBorder.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        vwBorder.layer.borderWidth = 1
    }
    
    func checkHandler(bool: Bool) {
        btnCheck.isSelected = bool
    }
}

//MARK:- ShipBillTVC
protocol ShipBillTVCDelegate: class {
    func tapEdit()
}

class ShipBillTVC: UITableViewCell {
    
    @IBOutlet weak var vwBorder: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbShipBill: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var svAddress: UIStackView!
    
    @IBOutlet weak var lbDelivery: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDeliveryAddr: UILabel!
    @IBOutlet weak var lbPhoneNo: UILabel!
    
    @IBOutlet weak var lbBilling: UILabel!
    @IBOutlet weak var lbBillingAddr: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    
    weak var delegate: ShipBillTVCDelegate?
    
    override func awakeFromNib() {
        vwBorder.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        vwBorder.layer.borderWidth = 1
        btnEdit.setTitle(kLb.edit.localized, for: .normal)
        
        lbShipBill.text = kLb.shipping_and_billing.localized
        lbDelivery.text = kLb.delivery_address.localized
        lbBilling.text = kLb.billing_address.localized
    }
    
    func checkHandler(bool: Bool) {
        btnCheck.isSelected = bool
    }
    
    @IBAction func editHandler(_ sender: Any) {
        delegate?.tapEdit()
    }
}

//MARK:- WalletVoucherTVC
protocol WalletVoucherTVCDelegate: class {
    func updateTf1Value(value: String?)
    func updateTf2Value(value: String?)
    func updatePayAmount(payAmount: Double?)
    func info1Tap()
    func info2Tap()
    func voucherTap()
}
class WalletVoucherTVC: UITableViewCell {
    
    @IBOutlet weak var lbUsePoints: UILabel!
    @IBOutlet weak var lbAvailPoints: UILabel!
    @IBOutlet weak var tfPoints: UITextField!
    @IBOutlet weak var lbUsePoints2: UILabel!
    @IBOutlet weak var lbAvailPoints2: UILabel!
    @IBOutlet weak var tfPoints2: UITextField!
    
    @IBOutlet weak var lbVoucher: UILabel!
    @IBOutlet weak var lbVoucherValue: UILabel!
    @IBOutlet weak var btnSelectVoucher: UIButton!
    
    var metaPointData: CheckoutEwalletModel?
    var metaCoinData: CheckoutEwalletModel?
    var selectedVoucher: CheckoutVoucherModel? = nil
    
    var metapointTfValue: String? = "0.00"
    var metacoinTfValue: String? = "0.00"
    var totalAmount: Double?
    var fixedPayAmount: Double?
    var payAmount: Double?
    
    var delegate: WalletVoucherTVCDelegate?
    
    override func awakeFromNib() {
        lbVoucher.text = kLb.vouchers.localized
        
        lbUsePoints.text = kLb.meta_coins.localized
        lbAvailPoints.text = "\(kLb.available_total.localized) \("\(metaCoinData?.balance ?? 0.0)".toDisplayCurrency())"
        
        lbUsePoints2.text = kLb.meta_points.localized
        lbAvailPoints2.text = "\(kLb.available_total.localized) \("\(metaPointData?.balance ?? 0.0)".toDisplayCurrency())"
        
        tfPoints.setRightPaddingPoints(16)
        tfPoints.setLeftPaddingPoints(16)
        tfPoints.applyCornerRadius(cornerRadius: tfPoints.bounds.height/2)
        tfPoints.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        tfPoints.layer.borderWidth = 1
        
        tfPoints2.setRightPaddingPoints(16)
        tfPoints2.setLeftPaddingPoints(16)
        tfPoints2.applyCornerRadius(cornerRadius: tfPoints.bounds.height/2)
        tfPoints2.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        tfPoints2.layer.borderWidth = 1
        
        tfPoints.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tfPoints2.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if let selectedVoucher = selectedVoucher {
            var amountDisc: Double = 0.0
            var discountText: String = ""
            
            if let fixedPayAmount = fixedPayAmount, let totalAmt = totalAmount {
                if selectedVoucher.discountType == DiscountType.percent.rawValue {
                    amountDisc = (totalAmt*Double(selectedVoucher.percentDisc ?? 0)) / 100.0
                    discountText = "\(selectedVoucher.percentDisc ?? 0)%"
                } else {
                    amountDisc = Double(selectedVoucher.amountDisc ?? "") ?? 0.0
                    discountText = "\(selectedVoucher.currencyCode ?? "") \(selectedVoucher.amountDisc ?? "")"
                }
                
                self.payAmount = fixedPayAmount - amountDisc
                self.fixedPayAmount = self.payAmount
                self.textFieldEditing(textField: tfPoints)
                self.textFieldEditing(textField: tfPoints2)
            }
            lbVoucherValue.textColor = .red
            lbVoucherValue.text = "\(discountText) \(kLb.discount.localized)"
        } else {
            lbVoucherValue.text = kLb.use_voucher.localized
            lbVoucherValue.textColor = .msBrown
        }
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        self.textFieldEditing(textField: textField)
    }
    
    func textFieldEditing(textField: UITextField) {
        if let keyInAmtStr = textField.text?.currencyInputFormatting(), var fixedPayAmt = fixedPayAmount {
            let metapointsBalance = metaPointData?.balance ?? 0.00
            let metapointsUnit = Double(metaPointData?.unit ?? 0)
            let metacoinBalance = metaCoinData?.balance ?? 0.00
            let metacoinUnit = Double(metaCoinData?.unit ?? 0)
            
            let balance = textField == tfPoints ? metacoinBalance : metapointsBalance
            let unit = textField == tfPoints ? metacoinUnit : metapointsUnit
            
            let doubleKeyInAmt = Double(keyInAmtStr.currencyWithoutGrouping()) ?? 0.00
            let doubleMetapointsTfAmt = Double(metapointTfValue?.currencyWithoutGrouping() ?? "") ?? 0.00
            let doubleMetacoinTfAmt = Double(metacoinTfValue?.currencyWithoutGrouping() ?? "") ?? 0.00
            let doubleUsableMetapointsAmt = doubleMetapointsTfAmt/Double(metaPointData?.unit ?? 0)
            let doubleUsableMetacoinAmt = doubleMetacoinTfAmt/Double(metaCoinData?.unit ?? 0)
            let tfPreviousValue = textField == tfPoints ? metacoinTfValue : metapointTfValue
            let usableDoubleAmt = (doubleKeyInAmt/unit)
            
            let doubleTotalAmt = doubleUsableMetapointsAmt + doubleUsableMetacoinAmt
            var toPayAmt = fixedPayAmt.roundedTwoDecimal - doubleTotalAmt.roundedTwoDecimal
            if toPayAmt.roundedTwoDecimal < 0.00 {
                toPayAmt = 0.00
            }
            
            var currentPayAmt: Double = 0.00
            currentPayAmt += textField == tfPoints ? (doubleMetapointsTfAmt/metapointsUnit).roundedTwoDecimal : (doubleMetacoinTfAmt/metacoinUnit).roundedTwoDecimal
            
            if toPayAmt > balance/unit && doubleKeyInAmt/unit > balance/unit {
                //Key in value more than wallet balance
                textField.resignFirstResponder()
                textField.text = "\(balance.roundedTwoDecimal)".toDisplayCurrency()
                currentPayAmt += balance/unit
            } else {
                
                if (toPayAmt == 0.00 && usableDoubleAmt < (Double(tfPreviousValue?.currencyWithoutGrouping() ?? "") ?? 0.00)/unit) || usableDoubleAmt < toPayAmt {
                    //Key in value is less than to pay amount
                    textField.text = keyInAmtStr
                    currentPayAmt += usableDoubleAmt
                } else {
                    //Key in value is more than to pay amount
                    let doubleAmtDeduct = textField == tfPoints ? doubleUsableMetapointsAmt : doubleUsableMetacoinAmt
                    let exceededAmt = (fixedPayAmt - doubleAmtDeduct) * unit
                    textField.resignFirstResponder()
                    textField.text = "\(exceededAmt.roundedTwoDecimal)".toDisplayCurrency()
                    currentPayAmt = fixedPayAmt
                }
            }
            
            if textField == tfPoints {
                metacoinTfValue = textField.text
                delegate?.updateTf1Value(value: textField.text)
            } else {
                metapointTfValue = textField.text
                delegate?.updateTf2Value(value: textField.text)
            }
            
            fixedPayAmt -= currentPayAmt
            payAmount = fixedPayAmt.roundedTwoDecimal
            delegate?.updatePayAmount(payAmount: payAmount)
        }
    }
    
    @IBAction func info1Handler(_ sender: Any) {
        delegate?.info1Tap()
    }
    
    @IBAction func info2Handler(_ sender: Any) {
        delegate?.info2Tap()
    }
    
    @IBAction func voucherHandler(_ sender: Any) {
        delegate?.voucherTap()
    }
}

//MARK:- OrderSummaryTVC
class OrderSummaryTVC: UITableViewCell {
    
    @IBOutlet weak var lbOrderSummary: UILabel!
    
    @IBOutlet weak var lbSubtotal: UILabel!
    @IBOutlet weak var lbSubtotalValue: UILabel!
    @IBOutlet weak var lbShippingFee: UILabel!
    @IBOutlet weak var lbShippingFeeValue: UILabel!
    
    @IBOutlet weak var lbMetaCoin: UILabel!
    @IBOutlet weak var lbMetaCoinValue: UILabel!
    @IBOutlet weak var lbMetaPoint: UILabel!
    @IBOutlet weak var lbMetaPointValue: UILabel!
    
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTotalDisc: UILabel!
    @IBOutlet weak var lbTotalDiscValue: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        lbOrderSummary.text = kLb.order_summary.localized
        lbMessage.text = kLb.your_order_is_eligible_for_free_delivery.localized
        lbSubtotal.text = kLb.subtotal.localized
        lbShippingFee.text = kLb.shipping.localized
        lbMetaCoin.text = kLb.meta_coins.localized
        lbMetaPoint.text = kLb.meta_points.localized
        lbTotalDisc.text = kLb.total_discount.localized
    }
}
