//
//  ProductDetailsVC.swift
//  Metastones
//
//  Created by Sonya Hew on 24/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import WebKit
import FSPagerView

enum ProductDetailsAction {
    case favorite
    case none
}

class ProductDetailsVC: UIViewController {

    let productViewModel = ProductViewModel()
    let profileViewModel = ProfileViewModel()
    let cartViewModel = CartViewModel()
    let appData = AppData.shared

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var navContainer: UIView!
    @IBOutlet weak var svBottom: UIStackView!
    @IBOutlet weak var widthConstraintSvBottom: NSLayoutConstraint!
    @IBOutlet weak var svShareFav: UIStackView!
    @IBOutlet weak var svBuyAddCart: UIStackView!
    @IBOutlet weak var btnWishlist: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var btnAddToBag: BrownButton!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            pagerView.delegate = self
            pagerView.dataSource = self
            pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            let width = UIScreen.main.bounds.width
            let height = maxHeight
            pagerView.itemSize = CGSize(width: width, height: height)
            pagerView.interitemSpacing = 0
            for subview in pagerView.subviews {
                subview.clipsToBounds = false
            }
        }
    }
    
    let popupManager = PopupManager.shared
    
    var webViewContentSize: CGSize? = CGSize.init()

    var productDetailsData = ProductDetailsModule()
    var priceData: PriceModule?
    var sizeSelectionArr: [Int] = []
    
    var currentIndex = 0
    let maxHeight = UIScreen.main.bounds.width
    
    var itemQty: Int = 1
    var itemCap: Int = 1 {
        didSet {
            tableView.reloadData()
        }
    }
    var apiOptionsIds: String = ""
    var callbackAction: ProductDetailsAction = .none
    var isAcademy: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.applyCornerRadius(cornerRadius: btnBack.bounds.height/2)
        setupTableView()
        if let optionsCount = productDetailsData.data?.options?.map({ $0.option }).count {
            sizeSelectionArr = [Int](repeatElement(0, count: optionsCount))
        }
        
        lbTitle.text = productDetailsData.data?.product?.productName?.capitalized ?? ""
        
        btnWishlist.setImage(productDetailsData.data?.product?.isWishlist ?? false ? #imageLiteral(resourceName: "icon-big-wishlist-on") : #imageLiteral(resourceName: "icon-big-wishlist-off"), for: .normal)
        btnAddToBag.setTitle(kLb.add_to_cart.localized, for: .normal)
        btnBuyNow.setTitle(kLb.buy_now.localized.capitalized, for: .normal)
        btnBuyNow.applyCornerRadius(cornerRadius: 24)
        
        if let prdType = productDetailsData.data?.product?.prdType {
            isAcademy = prdType == ProductType.academy.rawValue
            
            if isAcademy {
                let newConstraint = widthConstraintSvBottom.constraintWithMultiplier(4)
                view.removeConstraint(widthConstraintSvBottom)
                view.addConstraint(newConstraint)
                widthConstraintSvBottom.isActive = false
                newConstraint.isActive = true
                view.layoutIfNeeded()
                widthConstraintSvBottom = newConstraint
            }
            svShareFav.subviews[1].isHidden = isAcademy
            svBuyAddCart.subviews[1].isHidden = isAcademy
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heightConstraint.constant = maxHeight
        self.isEnableAddToCart(enable: isAcademy ? true : (priceData?.data?.qtyOnHand?.qtyOnHand ?? 0 > 0))
        
        if AppData.shared.isLoggedIn {
            switch callbackAction {
                case .favorite:
                    callbackAction = .none
                    favHandler(self)
                
                case .none:
                    return
            }
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 0.01
        tableView.sectionFooterHeight = 0.01
        
        vwContainer = tableView.tableHeaderView
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.addSubview(vwContainer)
        tableView.contentInset = UIEdgeInsets(top: maxHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -maxHeight)
        tableView.register(ProductDescTVC.self, forCellReuseIdentifier: "productDescTVC")
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareHandler(_ sender: Any) {
        if let shareUrl = productDetailsData.data?.product?.url {
            self.present(getShareActivity(shareItems: [shareUrl], sourceView: btnShare), animated: true)
        }
    }
    
    @IBAction func favHandler(_ sender: Any) {
        if isMemberUser(vc: self.navigationController) {
            if let prdMasterId = productDetailsData.data?.product?.id, let isFav = productDetailsData.data?.product?.isWishlist {
                profileViewModel.updateWishlist(prdMasterId: "\(prdMasterId)", isFav: isFav) { (proceed, data) in
                    if proceed {
                        self.productDetailsData.data?.product?.wishlist = isFav ? 0 : 1
                        self.btnWishlist.setImage(self.productDetailsData.data?.product?.isWishlist ?? false ? #imageLiteral(resourceName: "icon-big-wishlist-on") : #imageLiteral(resourceName: "icon-big-wishlist-off"), for: .normal)
                    }
                }
            }
        } else {
            callbackAction = .favorite
        }
    }
    
    @IBAction func addToBagHandler(_ sender: Any) {
        if let prdId = productDetailsData.data?.product?.id, let prdType = productDetailsData.data?.product?.prdType {
            cartViewModel.addCart(type: "ADD", prdId: "\(prdId)", qty: "\(itemQty)", optionId: apiOptionsIds, prdType: prdType) { (proceed, data) in
                if proceed {
                    if let prdData = data?.data?.products.filter({ $0?.prdMasterId == prdId }).first {
                        let addToCartVC = getVC(sb: "Sheet", vc: "AddToCartPopupVC") as! AddToCartPopupVC
                        addToCartVC.imgUrl = prdData?.imgPath
                        addToCartVC.prdName = prdData?.productName
                        addToCartVC.prdQty = "\(self.itemQty)"
                        addToCartVC.prdCurrCode = prdData?.currencyCode
                        addToCartVC.prdPrice = prdData?.unitPrice
                        addToCartVC.prdSizes = prdData?.optionName
                        
                        let header: CGFloat = 160
                        let contentHeight: CGFloat = 180
                        let btmPadding: CGFloat = hasTopNotch ? 48 : 0
                        getSheetedController(controller: addToCartVC, sizes: [.fixed(header+contentHeight+btmPadding)], currentVC: self) { (sc) in
                            let addToCartPopupVC = sc as! AddToCartPopupVC
                            if addToCartPopupVC.action == .viewCart {
                                DispatchQueue.main.async {
                                    self.navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func buyNowHandler(_ sender: Any) {
        if let prdId = productDetailsData.data?.product?.id, let prdType = productDetailsData.data?.product?.prdType {
            if isAcademy {
                if !appData.isLoggedIn {
                    popupManager.showAlert(destVC: popupManager.getGeneralPopup(desc: kLb.youre_almost_there.localized, strLeftText: kLb.continue_to_login.localized, strRightText: kLb.continue_as_guest.localized, style: .warning, isVertical: true)) { (btnTitle) in
                        if btnTitle == kLb.continue_to_login.localized {
                            let loginVC = getVC(sb: "Main", vc: "LoginPageVC") as! LoginPageVC
                            self.navigationController?.pushViewController(loginVC, animated: true)
                        }
                        if btnTitle == kLb.continue_as_guest.localized {
                            var currVCStack = self.navigationController?.viewControllers
                            let deliveryVC = getVC(sb: "Landing", vc: "DeliveryVC") as! DeliveryVC
                            deliveryVC.prdId = prdId
                            deliveryVC.prdType = prdType
                            deliveryVC.isAcademy = self.isAcademy
                            let guestDetailsVC = getVC(sb: "Profile", vc: "GuestDetailsVC") as! GuestDetailsVC
                            guestDetailsVC.type = .details //academy products can only "buy now"
                            guestDetailsVC.parentVC = deliveryVC
                            currVCStack?.append(contentsOf: [deliveryVC, guestDetailsVC])
                            self.navigationController?.setViewControllers(currVCStack ?? [], animated: true)
                        }
                    }
                } else {
                    let deliveryVC = getVC(sb: "Landing", vc: "DeliveryVC") as! DeliveryVC
                    deliveryVC.prdId = prdId
                    deliveryVC.prdType = prdType
                    navigationController?.pushViewController(deliveryVC, animated: true)
                }
                
            } else {
                cartViewModel.addCart(type: "ADD", prdId: "\(prdId)", qty: "\(itemQty)", optionId: apiOptionsIds, prdType: prdType) { (proceed, data) in
                    if proceed {
                        self.navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
                    }
                }
            }
        }
    }
    
    func callGetPrice() {
        self.productDetailsData.data?.priceRange = PriceRangeDataModel()
        self.itemQty = 1
        productViewModel.getPrice(productId: productDetailsData.data?.product?.id ?? 0, optionId: apiOptionsIds, qty: 1) { (proceed, data) in
            if proceed {
                if let data = data {
                    self.priceData = data
                    if let qtyOnHand = data.data?.qtyOnHand?.qtyOnHand, qtyOnHand > 0 {
                        self.isEnableAddToCart(enable: true)
                        
                    }
                }
            }
            if data?.err == 99 {
                self.priceData = PriceModule.init()
                self.isEnableAddToCart(enable: false)
            }
        }
    }
    
    func isEnableAddToCart(enable: Bool) {
        self.btnBuyNow.isUserInteractionEnabled = enable
        self.btnAddToBag.isUserInteractionEnabled = enable
        UIView.animate(withDuration: 0.2) {
            self.btnBuyNow.alpha = enable ? 1.0 : 0.5
            self.btnAddToBag.alpha = enable ? 1.0 : 0.5
        }
        self.tableView.reloadSections(IndexSet([0,2]), with: .automatic)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        print(offset)
        var headerImgTransform = CATransform3DIdentity

        
        if offset < 0 {
            navContainer.alpha = min(1, 1-abs(offset/maxHeight))
        } else {
            navContainer.alpha = 1
        }
        
        var headerRect = CGRect(x: 0, y: -maxHeight, width: maxHeight, height: maxHeight)
        if tableView.contentOffset.y < -maxHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
            let scale = 1+abs((maxHeight+offset)/120)
            headerImgTransform = CATransform3DScale(headerImgTransform, max(1, scale), max(1, scale), 1)
        }
        
        vwContainer.frame = headerRect
        pagerView.layer.transform = headerImgTransform
    }
}

extension ProductDetailsVC: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        pageControl.numberOfPages = productDetailsData.data?.images?.count ?? 0
        return productDetailsData.data?.images?.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)        
        cell.imageView?.loadWithCache(strUrl: productDetailsData.data?.images?[index].imgPath ?? "")
        cell.imageView?.contentMode = .scaleToFill
        cell.contentView.layer.shadowRadius = 0
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
    }
        
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}

extension ProductDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return productDetailsData.data?.options?.count ?? 0
        } else if section == 5 {
            return productDetailsData.data?.review?.reviews?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if let option = productDetailsData.data?.options?[indexPath.row] {
                let rowHeight: CGFloat = 54
                let verticalPadding: CGFloat = 24 + 44 //header title
                let rowCount: CGFloat = (CGFloat(option.option?.count ?? 0)/2).rounded(.up)
                let height: CGFloat = rowHeight*rowCount + verticalPadding
                return height
            }
        } else if indexPath.section == 3 {
            if let contentSize = webViewContentSize {
                if productDetailsData.data?.product?.longDesc?.contains("data:image") ?? false {
                    return contentSize.height + 132
                } else {
                    return contentSize.height + 36
                }
            }
        } else if indexPath.section == 4 {
            if productDetailsData.data?.review?.reviews?.count == 0 {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: //product name
            let cell = tableView.dequeueReusableCell(withIdentifier: "productTVC") as! ProductTVC
            if let product = productDetailsData.data?.product {
                cell.lbProductName.text = product.productName
                cell.showBestSeller(isShow: product.bestSeller == 0 ? false : true)
            }
            
            if let review = productDetailsData.data?.review {
                cell.lbRating.text = "\(review.totalReviews ?? 0) \(kLb.ratings.localized)"
                if let rating = productDetailsData.data?.review?.rounddownRating {
                    cell.setupRatingStars(starCount: rating)
                } else {
                    cell.setupRatingStars(starCount: 0)
                }
            }
            
            cell.lbRating.isHidden = true
            cell.svRating.isHidden = true
            cell.svHeightConstraint.constant = 0
            
            cell.selectionStyle = .none
            return cell
            
//        case 1: //sizes
//            let cell = tableView.dequeueReusableCell(withIdentifier: "productSizeTVC") as! ProductSizeTVC
//            if let options = productDetailsData.data?.options?[indexPath.row] {
//                cell.lbTitle.text = options.title
//                cell.lbValue.text = productDetailsData.data?.options?[indexPath.row].option?.first?.desc
//            }
//            cell.selectionStyle = .none
//            return cell
            
        case 1: //sizes
            let cell = tableView.dequeueReusableCell(withIdentifier: "productSizeCTVC") as! ProductSizeCTVC
            cell.optionsData = productDetailsData.data?.options?[indexPath.row]
            cell.lbTitle.text = productDetailsData.data?.options?[indexPath.row].title?.localized
            cell.delegate = self
            cell.sizeSelectionArr = sizeSelectionArr
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            return cell
            
        case 2: //qty
            let cell = tableView.dequeueReusableCell(withIdentifier: "productQtyTVC") as! ProductQtyTVC
            cell.delegate = self
            cell.count = itemQty
            cell.isSelectedOption = !self.sizeSelectionArr.contains(0)
            
            if cell.isSelectedOption {
                if let qtyOnHand = priceData?.data?.qtyOnHand?.qtyOnHand, qtyOnHand > 0 {
                    cell.cap = qtyOnHand
                    cell.btnAdd.isUserInteractionEnabled = true
                    cell.btnMinus.isUserInteractionEnabled = true
                } else {
                    cell.btnAdd.isUserInteractionEnabled = false
                    cell.btnMinus.isUserInteractionEnabled = false
                }
            }
            
            cell.lbPrice.textColor = .msBrown
            if let priceRange = productDetailsData.data?.priceRange, let currencyCode = priceRange.currencyCode, let minPrice = priceRange.minPrice, let maxPrice = priceRange.maxPrice {
                if minPrice == maxPrice {
                    cell.lbPrice.text = "\(currencyCode) \(minPrice.toDisplayCurrency())"
                } else {
                    cell.lbPrice.text = "\(currencyCode) \(minPrice.toDisplayCurrency()) - \(currencyCode) \(maxPrice.toDisplayCurrency())"
                }
                
            } else if let currencyCode = priceData?.data?.currencyCode, let price = priceData?.data?.price {
                cell.lbPrice.text = "\(currencyCode) \(price.toDisplayCurrency())"
                
            } else {
                cell.lbPrice.textColor = .msBrown
                cell.lbPrice.text = kLb.product_sold_out.localized
            }
            
            cell.stackView.subviews[0].isHidden = isAcademy
            
            cell.selectionStyle = .none
            return cell
            
        case 3: //desc
            let cell = tableView.dequeueReusableCell(withIdentifier: "productDescTVC") as! ProductDescTVC
            cell.webView.backgroundColor = .clear
            cell.webView.navigationDelegate = self
            cell.webView.uiDelegate = self
            cell.webView.loadHTMLStringWithDeviceWidth(content: productDetailsData.data?.product?.longDesc ?? "", baseURL: nil)
            cell.selectionStyle = .none
            cell.awakeFromNib()
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewHeaderTVC") as! ReviewHeaderTVC
            cell.selectionStyle = .none
            return cell
            
        case 5: //reviews
            let cell = tableView.dequeueReusableCell(withIdentifier: "productReviewTVC") as! ProductReviewTVC
            if let review = productDetailsData.data?.review?.reviews?[indexPath.row] {
                cell.lbName.text = review.nickName
                cell.lbDate.text = review.createdAt
                cell.lbComment.text = review.review
                cell.setupRatingStars(starCount: review.rating ?? 0)
                cell.ivPhoto.loadWithCache(strUrl: review.memberImgPath)
            }
            cell.awakeFromNib()
            cell.selectionStyle = .none
            return cell
        
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 {
//            currentIndex = indexPath.row
//            getPickerSheetedController(dataArr: productDetailsData.data?.options?[indexPath.row].option?.map({"\($0.desc ?? "")"}) ?? [], forVC: self, selectedRow: sizeSelectionArr[currentIndex]) { (btnTitle, btnIndex) in
//
//                let cell = tableView.cellForRow(at: indexPath) as! ProductSizeTVC
//                cell.lbValue.text = btnTitle
//                self.sizeSelectionArr[indexPath.row] = btnIndex
//
//                var optionId: [Int] = []
//                if let options = self.productDetailsData.data?.options?.map({$0.option}) {
//                    for (index, opt) in options.enumerated() {
//                        optionId.append(opt?[self.sizeSelectionArr[index]].code ?? 0)
//                    }
//                }
//
//                self.apiOptionsIds = "[\(optionId.map({"\($0)"}).joined(separator: ","))]"
//                self.callGetPrice()
//            }
//        }
    }
}

extension ProductDetailsVC: ProductQtyTVCDelegate {
    func updateQty(qty: Int) {
        itemQty = qty
    }
    
    func disableAction() {
        popupManager.showAlert(destVC: popupManager.getAlertPopup(desc: kLb.please_select_options.localized))
    }
}

extension ProductDetailsVC: ProductSizeCVCDelegate {
    func didSelectSize(category: Int, itemIndex: Int) {
        
        self.sizeSelectionArr[category] = itemIndex

//        var optionId: [Int] = []
//        if let options = self.productDetailsData.data?.options?.map({$0.option}) {
//            for (index, opt) in options.enumerated() {
//                optionId.append(opt?[self.sizeSelectionArr[index]].code ?? 0)
//            }
//        }

        if !self.sizeSelectionArr.contains(0) {
            self.apiOptionsIds = "[\(self.sizeSelectionArr.map({"\($0)"}).joined(separator: ","))]"
            self.callGetPrice()
        }
    }
}

extension ProductDetailsVC: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.htmlCorrector()
        if let height = webViewContentSize?.height, height <= CGFloat(0) {
            webView.evaluateJavaScript("document.readyState") { (complete, error) in
                if complete != nil {
                    webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                        self.webViewContentSize?.height = (height as! CGFloat)*1.5
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
}

//MARK:- ProductTVC
class ProductTVC: UITableViewCell {
    
    @IBOutlet weak var svRating: UIStackView!
    @IBOutlet weak var lbBestSeller: UILabel!
    @IBOutlet weak var lbRating: UILabel!
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var vwBestSeller: UIView!
    @IBOutlet weak var svTop: UIStackView!
    @IBOutlet weak var svLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var svHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var ivStars: [UIImageView]!
    
    override func awakeFromNib() {
        lbBestSeller.text = kLb.best_seller.localized.capitalized
    }
    
    func setupRatingStars(starCount: Int) {
        for (index, star) in ivStars.enumerated() {
            if index < starCount {
                star.image = #imageLiteral(resourceName: "star-on.png")
            } else {
                star.image = #imageLiteral(resourceName: "star-off")
            }
        }
    }
    
    func showBestSeller(isShow: Bool) {
        svTop.subviews.first?.isHidden = !isShow
        svLeftConstraint.constant = isShow ? 32 : 26
    }
}


//MARK:- ProductSizeTVC
class ProductSizeTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbValue: UILabel!
    
    override func awakeFromNib() {
    }
}


//MARK:- ProductQtyTVC
protocol ProductQtyTVCDelegate: class {
    func updateQty(qty: Int)
    func disableAction()
}
class ProductQtyTVC: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    weak var delegate: ProductQtyTVCDelegate?
    
    var count = 0 {
        didSet {
            lbCount.text = "\(count)"
        }
    }
    var cap = 0
    var isSelectedOption: Bool = false
    
    override func awakeFromNib() {
        lbTitle.text = kLb.quantity.localized
        lbCount.text = "\(count)"
    }
    
    @IBAction func minusHandler(_ sender: Any) {
        if isSelectedOption {
            if count > 1 {
                count-=1
            }
            lbCount.text = "\(count)"
            delegate?.updateQty(qty: count)
            
        } else {
            delegate?.disableAction()
        }
    }
    
    @IBAction func addHandler(_ sender: Any) {
        if isSelectedOption {
            if count < cap {
                count+=1
            }
            lbCount.text = "\(count)"
            delegate?.updateQty(qty: count)
            
        } else {
            delegate?.disableAction()
        }
    }
}

//MARK:- ReviewHeaderTVC
class ReviewHeaderTVC: UITableViewCell {
    
    @IBOutlet weak var lbReview: UILabel!
    
    override func awakeFromNib() {
        lbReview.text = kLb.review_and_rate.localized
    }
}


//MARK:- ProductReviewTVC
class ProductReviewTVC: UITableViewCell {
    
    @IBOutlet weak var svRating: UIStackView!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbComment: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    @IBOutlet var ivStars: [UIImageView]!
    
    override func awakeFromNib() {
        ivPhoto.applyCornerRadius(cornerRadius: 18)
        ivPhoto.layer.borderColor = UIColor.black.cgColor
        ivPhoto.layer.borderWidth = 0.5
    }
    
    func setupRatingStars(starCount: Int) {
        for (index, star) in ivStars.enumerated() {
            if index < starCount {
                star.image = #imageLiteral(resourceName: "star-on.png")
            } else {
                star.image = #imageLiteral(resourceName: "star-off")
            }
        }
    }
}

//MARK:- ProductDescTVC
class ProductDescTVC: UITableViewCell {
    
    let webView: WKWebView = {
        let view = WKWebView(frame: CGRect.zero)
        view.scrollView.isScrollEnabled = true
        view.scrollView.bounces = false
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.contentSize.height = 1
        view.scrollView.maximumZoomScale = 1
        return view
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xE5E5E5)
        return view
    }()
    
    let lbTitle: UILabel = {
        let lb = UILabel()
        lb.text = kLb.product_info.localized
        lb.textColor = UIColor(hex: 0x1C1C1C)
        lb.font = .systemFont(ofSize: 14, weight: .medium)
        return lb
    }()
    
    override func awakeFromNib() {
        contentView.addSubview(lbTitle)
        lbTitle.translatesAutoresizingMaskIntoConstraints = false
        lbTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        lbTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32).isActive = true
        
        contentView.addSubview(webView)
        contentView.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: lbTitle.bottomAnchor, constant: 28).isActive = true
        webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18).isActive = true
        webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28).isActive = true
        
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
    }
    
    func setupWithoutTitle() {
        awakeFromNib()
        lbTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        lbTitle.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
}

protocol ProductSizeCVCDelegate: class {
    func didSelectSize(category: Int, itemIndex: Int)
}

//MARK:- ProductSizeCTVC
class ProductSizeCTVC: UITableViewCell {
    
    weak var delegate: ProductSizeCVCDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var optionsData: OptionsModel?
    var sizeSelectionArr: [Int] = []
    
    override func awakeFromNib() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension ProductSizeCTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsData?.option?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productSizeCVC", for: indexPath) as! ProductSizeCVC
        cell.lbTitle.text = optionsData?.option?[indexPath.item].desc
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideMargin: CGFloat = 32*2
        let cellGap: CGFloat = 14
        let width = (UIScreen.main.bounds.width - sideMargin - cellGap)/2
        let height: CGFloat = 45
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductSizeCVC
        cell.setSelected(isSelected: true)
        delegate?.didSelectSize(category: tag, itemIndex: optionsData?.option?[indexPath.item].code ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductSizeCVC
        cell.setSelected(isSelected: false)
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
//            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
//        }
//    }
}

//MARK:- ProductSizeCVC
class ProductSizeCVC: UICollectionViewCell {
    
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        vwContainer.applyCornerRadius(cornerRadius: 4)
        vwContainer.layer.borderColor = UIColor.msBrown.cgColor
        vwContainer.layer.borderWidth = 1
    }
    
    func setSelected(isSelected: Bool) {
        if isSelected {
            lbTitle.textColor = .white
            vwContainer.backgroundColor = .msBrown
        } else {
            lbTitle.textColor = UIColor(hex: 0x242424)
            vwContainer.backgroundColor = .white
        }
    }
}
