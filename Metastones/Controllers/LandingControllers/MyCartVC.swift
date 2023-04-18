//
//  MyCartVC.swift
//  Metastones
//
//  Created by Sonya Hew on 31/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum ProductType: String {
    case standard = "Standard"
    case custom = "Custom"
    case academy = "Academy"
}

class MyCartVC: UIViewController {
    
    let popup = PopupManager.shared
    let appData = AppData.shared
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var vwBottom: UIView!
    
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var btnCheckout: UIButton!
    
    let refresher = UIRefreshControl()
    let cartViewModel = CartViewModel()
    let productViewModel = ProductViewModel()
    var cartList: CartListModel? {
        didSet {
            isAvailableCheckout = cartList?.data?.products.filter({ $0?.checked == 1 && $0?.validity == CartItemStatus.active.rawValue }).count ?? 0 > 0
        }
    }
    var noData: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.5) {
                self.vwBottom.isHidden = self.noData
                self.btnDelete.isHidden = self.noData
            }
        }
    }
    
    var totalAmt: String? {
        didSet {
            let attribute = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.msBrown]
            let labelText = NSAttributedString(string: " \(kLb.total.localized): ")
            let valueText: NSMutableAttributedString = NSMutableAttributedString(string: "\(self.cartList?.data?.currencyCode ?? "")\(totalAmt?.toDisplayCurrency() ?? "")", attributes: attribute)
            let totalPrice = NSMutableAttributedString(attributedString: labelText)
            totalPrice.append(valueText)
            
            self.lbTotal.attributedText = totalPrice
        }
    }
    
    var isAvailableCheckout: Bool = true {
        didSet {
            btnCheckout.alpha = isAvailableCheckout ? 1.0 : 0.5
            btnCheckout.isUserInteractionEnabled = isAvailableCheckout
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFooter()
        
        lbTitle.text = kLb.my_cart.localized.capitalized
        btnDelete.setTitle(kLb.delete.localized, for: .normal)
        
        lbTotal.text = kLb.total.localized
        btnCheckout.setTitle(kLb.check_out.localized, for: .normal)
        
        setupData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedSectionFooterHeight = 20
        tableView.register(UINib(nibName: "CreateCartTVC", bundle: Bundle.main), forCellReuseIdentifier: "createCartTVC")
        tableView.register(UINib(nibName: "CreateCartTVHC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "createCartTVHC")
        tableView.register(UINib(nibName: "CreateCartTVFC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "createCartTVFC")
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
    }
    
    func setupFooter() {
        btnCheckout.applyCornerRadius(cornerRadius: btnCheckout.bounds.height/2)
        //btnCheckout.addShadow(withRadius: 15, opacity: 0.3, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 6))
        
        vwBottom.addShadow(withRadius: 6, opacity: 0.1, color: UIColor.black.cgColor, offset: CGSize(width: 3, height: 0))
    }
    
    func setupData() {
        cartViewModel.getCart { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.cartList = data
                self.noData = self.cartList?.data?.products.count == 0
                self.totalAmt = self.cartList?.data?.totalAmount
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshData() {
        setupData()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteHandler(_ sender: Any) {
        let selectedCartItem = cartList?.data?.products.filter({ $0?.checked == 1 }).map({ $0 })
        if let selectedCartItem = selectedCartItem, selectedCartItem.count > 0 {
            deleteProducts(products: selectedCartItem)
        }
    }
    
    func deleteProducts(products: [CartItemModel?]) {
        var selectedCartItem = products
        if selectedCartItem.count > 0 {
            for (index, item) in selectedCartItem.enumerated() {
                if index == 0, let prdCartId = item?.prdCartId, let prdType = item?.prdType {
                    cartViewModel.addCart(type: "REMOVE", prdCartId: "\(prdCartId)", prdType: prdType, groupId: item?.groupId) { (proceed, data) in
                        if proceed {
                            self.cartList = data
                            self.noData = self.cartList?.data?.products.count == 0
                            self.totalAmt = self.cartList?.data?.totalAmount
                            selectedCartItem.remove(at: index)
                            self.deleteProducts(products: selectedCartItem)
                        }
                    }
                }
            }
        } else {
            setupData()
        }
    }
    
    @IBAction func checkoutHandler(_ sender: Any) {
        if appData.appSetting?.checkout == 0 {
            popup.showAlert(destVC: popup.getComingSoonPopup(title: kLb.coming_soon.localized, desc: ""))
        } else {
            if !self.appData.isLoggedIn && !self.noData {
                self.popup.showAlert(destVC: self.popup.getGeneralPopup(desc: kLb.youre_almost_there.localized, strLeftText: kLb.continue_to_login.localized, strRightText: kLb.continue_as_guest.localized, style: .warning, isVertical: true)) { (btnTitle) in
                    if btnTitle == kLb.continue_to_login.localized {
                        let loginVC = getVC(sb: "Main", vc: "LoginPageVC") as! LoginPageVC
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                    if btnTitle == kLb.continue_as_guest.localized {
                        var currVCStack = self.navigationController?.viewControllers
                        let deliveryVC = getVC(sb: "Landing", vc: "DeliveryVC") as! DeliveryVC
                        let guestDetailsVC = getVC(sb: "Profile", vc: "GuestDetailsVC") as! GuestDetailsVC
                        guestDetailsVC.type = .address //academy products can only "buy now"
                        guestDetailsVC.parentVC = deliveryVC
                        currVCStack?.append(contentsOf: [deliveryVC, guestDetailsVC])
                        self.navigationController?.setViewControllers(currVCStack ?? [], animated: true)
                    }
                }
            } else {
                navigationController?.pushViewController(getVC(sb: "Landing", vc: "DeliveryVC"), animated: true)
            }
        }
    }
}

extension MyCartVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return noData ? 1 : self.cartList?.data?.products.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noData {
            return 1
        }
        
        if let beadCount = self.cartList?.data?.products[section]?.bead?.count, beadCount > 0 {
            return beadCount+1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /* Temporary usage */
        if noData {
            return UIView()
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "createCartTVHC") as! CreateCartTVHC
        if self.cartList?.data?.products[section]?.bead?.count ?? 0 > 0 {
            header.data = self.cartList?.data?.products[section]
            header.btnCheck.isSelected = self.cartList?.data?.products[section]?.checked == 1
            header.delegate = self
            return header
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        /* Temporary usage */
        //return 0.01
        if noData {
            return 0.01
        }
        
        if self.cartList?.data?.products[section]?.bead?.count ?? 0 > 0  {
            return 46
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Temporary usage */
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.lbMsg.text = kLb.no_orders_yet.localized
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        if self.cartList?.data?.products[indexPath.section]?.bead?.count ?? 0 > 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createCartTVC", for: indexPath) as! CreateCartTVC
            cell.data =  indexPath.row == 0 ? self.cartList?.data?.products[indexPath.section] : self.cartList?.data?.products[indexPath.section]?.bead?[indexPath.row-1]
            cell.vwSeparator.isHidden = self.cartList?.data?.products[indexPath.section]?.bead?.count != indexPath.row
            cell.awakeFromNib()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cartTVC", for: indexPath) as! CartTVC
            cell.delegate = self
            cell.tableView = tableView
            cell.data = cartList?.data?.products[indexPath.section]
            cell.awakeFromNib()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        /* Temporary usage */
        return UIView()
        
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "createCartTVFC") as! CreateCartTVFC
        footer.tableView = tableView
        if section == 1 {
            return footer
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        /* Temporary usage */
        return 0.01
        
        if section == 1 {
            return UITableView.automaticDimension
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product = cartList?.data?.products[indexPath.section] {
            if let prdType = product.prdType {
                if prdType == ProductType.standard.rawValue {
                    if let prdId = product.prdMasterId {
                        productViewModel.getProductDetails(productId: prdId) { (proceed, data) in
                            if proceed {
                                let vc = getVC(sb: "Landing", vc: "ProductDetailsVC") as! ProductDetailsVC
                                if let data = data {
                                    vc.productDetailsData = data
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                    
                } else {
                    let vc = getVC(sb: "Create", vc: "PreviewVC") as! PreviewVC
                    vc.cartItem = product
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension MyCartVC: CartTVCDelegate {
    func updateCartList(cartList: CartListModel?) {
        self.cartList = cartList
        self.noData = self.cartList?.data?.products.count == 0
        self.totalAmt = self.cartList?.data?.totalAmount
        self.tableView.reloadData()
    }
}

//MARK:- CartTVC
protocol CartTVCDelegate: class {
    func updateCartList(cartList: CartListModel?)
}

enum CartItemStatus: String {
    case active = "A"
    case exceededQtyLimit = "E"
    case invalidPrd = "I"
}

class CartTVC: UITableViewCell {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var lbVoucherEligibility: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbStrikePrice: UILabel!
    @IBOutlet weak var lbQty: UILabel!
    @IBOutlet weak var vwSeparator: UIView!
    @IBOutlet weak var lbMsgTitle: UILabel!
    @IBOutlet weak var lbMsgDesc: UILabel!
    @IBOutlet weak var lbExpansion: UILabel!
    @IBOutlet weak var constraintTopVwGiftCard: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightVwGiftCard: NSLayoutConstraint!
    
    @IBOutlet weak var tfReceiverName: UITextField!
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var tfUserName: UITextField!
    
    @IBOutlet weak var svMessage: UIStackView!
    
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var vwQty: UIView!
    
    let cartViewModel = CartViewModel()
    
    var tableView = UITableView()
    var isMsgHidden = true
    var allowAdd = true
    var allowMinus = true
    var data: CartItemModel?
    
    weak var delegate: CartTVCDelegate?
    
    override func awakeFromNib() {
        lbMsgTitle.text = kLb.do_you_want_write_gift_card_message.localized
        lbMsgDesc.text = kLb.keep_it_short_and_sweet_or_pour_your_feelings_out.localized
        
        /*Temporary hide*/
        lbMsgTitle.isHidden = true
        lbMsgDesc.isHidden = true
        lbExpansion.isHidden = true
        vwSeparator.isHidden = true
        constraintTopVwGiftCard.constant = 0
        constraintHeightVwGiftCard.constant = 0
        
        btnCheck.isSelected = data?.checked == 1
        ivProduct.loadWithCache(strUrl: data?.imgPath)
        lbProductName.text = "\(data?.productName ?? "")\n\(data?.optionName?.joined(separator: "\n") ?? "")"
        lbQty.text = "\(data?.qty ?? 0)"
        lbPrice.textColor = .black
        lbVoucherEligibility.textColor = .red
        lbVoucherEligibility.text = (data?.voucher ?? 1) == 1 ? "" : kLb.not_eligible_to_use_voucher.localized
        lbVoucherEligibility.isHidden = true
        lbStrikePrice.isHidden = true
        
        //Strike Price
        let haveDiscount = data?.discount != ""
        if haveDiscount {
            let attributeNormalPrice = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
            let normalPrice: NSMutableAttributedString =  NSMutableAttributedString(string: "\(data?.currencyCode ?? "") \(data?.oriUnitPrice ?? "")", attributes: attributeNormalPrice)
            normalPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, normalPrice.length))
            lbStrikePrice.attributedText = normalPrice
        } else {
            lbStrikePrice.text = ""
        }
        
        switch data?.validity {
        case CartItemStatus.exceededQtyLimit.rawValue:
            //btnAdd.isUserInteractionEnabled = false
            allowAdd = false
            allowMinus = true
            lbPrice.textColor = .red
            lbPrice.text = kLb.exceed_quantity_limit.localized
            lbPrice.font = .boldSystemFont(ofSize: 12)
            
        case CartItemStatus.invalidPrd.rawValue:
            //btnMinus.isUserInteractionEnabled = false
            //btnAdd.isUserInteractionEnabled = false
            allowAdd = false
            allowMinus = false
            lbPrice.textColor = .red
            lbPrice.text = kLb.unavailable_product.localized
            lbPrice.font = .boldSystemFont(ofSize: 12)
            
        default:
            allowAdd = true
            allowMinus = true
            lbVoucherEligibility.isHidden = (data?.voucher ?? 1) == 1
            lbStrikePrice.isHidden = !haveDiscount
            
            //Discount Price and Percent
            let attributePrice = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]
            let price: NSMutableAttributedString =  NSMutableAttributedString(string: "\(data?.currencyCode ?? "")\(data?.unitPrice?.toDisplayCurrency() ?? "")", attributes: attributePrice)
            
            let attributeDiscount = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.red]
            let discount: NSMutableAttributedString =  NSMutableAttributedString(string: "(\(data?.discount ?? ""))", attributes: attributeDiscount)
            
            if haveDiscount {
                price.append(NSMutableAttributedString(string: " "))
                price.append(discount)
                lbPrice.attributedText = price
            } else {
                lbPrice.attributedText = price
            }
        }
        
        svMessage.subviews[0].isHidden = true
        for tf in [tfReceiverName, tfMessage, tfUserName] {
            tf?.layer.borderColor = UIColor(hex: 0xBCBCBC).cgColor
            tf?.layer.borderWidth = 1
            tf?.applyCornerRadius(cornerRadius: 4)
            tf?.setLeftPaddingPoints(16)
            tf?.setRightPaddingPoints(16)
            tf?.attributedPlaceholder = NSAttributedString(string: "Field", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xC7C7C7)])
        }
        
        for vw in [svButtons, btnMinus, vwQty, btnAdd] {
            vw?.layer.borderWidth = 1
            vw?.layer.borderColor = UIColor(hex: 0xBCBCBC).cgColor
        }
    }
    
    @IBAction func checkHandler(_ sender: Any) {
        let btn = sender as! UIButton
        if let prdCartId = data?.prdCartId, let prdType = data?.prdType {
            cartViewModel.addCart(prdCartId: "\(prdCartId)", checked: !btn.isSelected ? "1" : "0", prdType: prdType, groupId: data?.groupId) { (proceed, data) in
                if proceed {
                    self.delegate?.updateCartList(cartList: data)
                    btn.isSelected = !btn.isSelected
                }
            }
        }
    }
    
    @IBAction func infoHandler(_ sender: Any) {
        let popupManager = PopupManager.shared
        var arrContent : [String] = []
        arrContent.append("\(kLb.weight.localized): \(data?.weight ?? "")")
        arrContent.append("\(kLb.domestic.localized): \((data?.domestic ?? 0).yesNo)")
        arrContent.append("\(kLb.international.localized): \((data?.international ?? 0).yesNo)")
        arrContent.append("\(kLb._return.localized): \((data?.returnP ?? 0).yesNo)")
        arrContent.append("\(kLb.exchange.localized): \((data?.exchange ?? 0).yesNo)")
        arrContent.append("\(kLb.warranty.localized): \((data?.warranty ?? 0).yesNo)")
        arrContent.append("\(kLb.refund.localized): \((data?.refund ?? 0).yesNo)")
        popupManager.showAlert(destVC: popupManager.getMsgOnlyPopup(desc: arrContent.joined(separator: "\n")))
    }
    
    @IBAction func minusHandler(_ sender: Any) {
        if allowMinus {
            let currentQty = Int(lbQty.text ?? "") ?? 0
            if let prdId = data?.prdMasterId, let optionId = data?.optionId, let prdCartId = data?.prdCartId, let prdType = data?.prdType {
                cartViewModel.addCart(prdId: "\(prdId)" , qty: "\(currentQty-1)", optionId: optionId, prdCartId: "\(prdCartId)", prdType: prdType) { (proceed, data) in
                    if proceed {
                        self.delegate?.updateCartList(cartList: data)
                        //self.lbQty.text = proceed ? "\(currentQty-1)" : "\(currentQty)"
                    }
                }
            }
        }
    }
    
    @IBAction func addHandler(_ sender: Any) {
        if allowAdd {
            let currentQty = Int(lbQty.text ?? "") ?? 0
            if let prdId = data?.prdMasterId, let optionId = data?.optionId, let prdCartId = data?.prdCartId, let prdType = data?.prdType {
                cartViewModel.addCart(prdId: "\(prdId)" , qty: "\(currentQty+1)", optionId: optionId, prdCartId: "\(prdCartId)", prdType: prdType) { (proceed, data) in
                    if proceed {
                        self.delegate?.updateCartList(cartList: data)
                        //self.lbQty.text = proceed ? "\(currentQty+1)" : "\(currentQty)"
                    }
                }
            }
        }
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
