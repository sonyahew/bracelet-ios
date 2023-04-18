//
//  ProductListingVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 23/04/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class ProductListingVC: UIViewController {
    
    let productViewModel = ProductViewModel()
    let profileViewModel = ProfileViewModel()
    weak var delegate: MenuDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    
    //cart
    @IBOutlet weak var btnCart: UIButton!
    @IBOutlet weak var vwIndicator: UIView!
    @IBOutlet weak var lbIndicator: UILabel!
    
    //top bar filters
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var segmentContainer: UIView!
    
    //filters
    @IBOutlet weak var lbSort: UILabel!
    @IBOutlet weak var lbFilters: UILabel!
    
    let appData = AppData.shared
    let segmentControl = ScrollableSegmentedControl()
    let refresher = UIRefreshControl()
    
    var collectionTitles: [String] = []
    var selectionList: [ProductCategoryModel?] = []
    var filterList: [PrdFilterDataModel?] = []
    
    var currentSelectedIndex: Int = 0
    var collectionCurrentIndex: Int = 0
    var noData : Bool = true
    var categoryFromMenu: Int?
    
    private var apiCollectionPage : [Int]? = []
    private var apiCollectionTotalPage : [Int]? = []
    private var productList : [[ProductListDataModel]]? = []
    private var selectedCategoryIdList : [String]? = []
    private var selectedCategoryNameList : [String]? = [] {
        didSet {
            lbCategory.text = selectedCategoryNameList?[currentSelectedIndex]
        }
    }
    private var selectedSortByList : [String]? = []
    private var selectedFilterList: [String]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCartIndicator()
        setupCollectionView()
        setupSelection()
        
        lbSort.text = kLb.sort.localized
        lbFilters.text = kLb.filters.localized
        lbTitle.text = kLb.products_collection.localized.capitalized
        
        lbTitle.text = kLb.online_course.localized
        
        self.stackView.subviews[2].isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lbIndicator.text = "\(appData.data?.cartItemCount ?? 0)"
        self.btnLive.hideShowBtnLive()
    }
    
    func menuClosed() {
        lbIndicator.text = "\(appData.data?.cartItemCount ?? 0)"
        if let category = self.categoryFromMenu {
            self.segmentControl.selectedSegmentIndex = category
        }
    }
    
    func setupCartIndicator() {
        vwIndicator.applyCornerRadius(cornerRadius: vwIndicator.bounds.height/2)
    }
    
    func setupSegmentView() {
        //add segments here
        for (index, title) in collectionTitles.enumerated() {
            segmentControl.insertSegment(withTitle: title, at: index)
        }
        segmentControl.segmentStyle = .textOnly
        segmentControl.underlineSelected = true
        segmentControl.fixedSegmentWidth = false
        segmentControl.segmentContentColor = .msBrown
        segmentControl.selectedSegmentContentColor = UIColor(hex: 0x1D2236)
        segmentControl.tintColor = UIColor(hex: 0x1D2236)
        segmentControl.selectedSegmentIndex = currentSelectedIndex
        segmentControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        segmentContainer.addSubviewAndPinEdges(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 2).isActive = true
        segmentControl.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 2).isActive = true
        
        stackView.subviews[1].isHidden = true
    }
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: "ListingCVC", bundle: nil), forCellWithReuseIdentifier: "listingCVC")
        collectionView.register(UINib(nibName: "EmptyDataCVC", bundle: nil), forCellWithReuseIdentifier: "emptyDataCVC")
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refresher)
        collectionView.isHidden = true
    }
    
    @objc func refreshData() {
        noData = true
        apiCollectionPage?[currentSelectedIndex] = 1
        apiCollectionTotalPage?[currentSelectedIndex] = 1
        productList?[currentSelectedIndex] = []
        callSingleCollectionAPI()
    }
    
    func setupSelection() {
        productViewModel.getProductCategory(categoryType: "online-course") { (proceed, data) in
            if proceed {
                self.selectionList = data?.data ?? []
                for item in self.selectionList {
                    if let itemName = item?.name {
                        self.collectionTitles.append(itemName.localized)
                    }
                }
                self.productViewModel.getProductFilters { (proceed, data) in
                    if proceed {
                        self.filterList = data?.data ?? []
                    }
                }
                self.setupData()
                self.setupSegmentView()
            }
        }
    }
    
    func initialData() {
        collectionCurrentIndex = 0
        apiCollectionPage = []
        apiCollectionTotalPage = []
        selectedSortByList = []
        selectedFilterList = []
        selectedCategoryIdList = []
        productList = []
        
        for _ in collectionTitles {
            apiCollectionPage?.append(1)
            apiCollectionTotalPage?.append(1)
            selectedSortByList?.append("")
            selectedFilterList?.append("")
            selectedCategoryIdList?.append("")
            selectedCategoryNameList?.append("")
            productList?.append([])
        }
        
        setupCategory()
    }
    
    func setupCategory() {
        if let categoryId = self.selectionList[self.collectionCurrentIndex]?.children?.first?.id, let categoryName = self.selectionList[self.collectionCurrentIndex]?.children?.first?.name {
            
            self.selectedCategoryIdList?[self.collectionCurrentIndex] = "\(categoryId)"
            self.selectedCategoryNameList?[self.collectionCurrentIndex] = categoryName
            
        } else if let categoryMainId = self.selectionList[self.collectionCurrentIndex]?.id {
            self.selectedCategoryIdList?[self.collectionCurrentIndex] = "\(categoryMainId)"
        }
    }
    
    func setupData() {
        initialData()
        callAllCollectionAPI()
    }
    
    func callAllCollectionAPI() {
        productViewModel.getProductList(page: apiCollectionPage?[collectionCurrentIndex], sortBy: selectedSortByList?[collectionCurrentIndex], categoryId: selectedCategoryIdList?[collectionCurrentIndex], filter: selectedFilterList?[collectionCurrentIndex]) { (proceed, data) in
            
            if self.collectionView.isHidden {
                self.collectionView.isHidden = false
            }
            
            if proceed {
                self.productList?[self.collectionCurrentIndex] = data?.data?.products ?? []
                self.apiCollectionPage?[self.collectionCurrentIndex] = data?.data?.currentPage ?? 1
                self.apiCollectionTotalPage?[self.collectionCurrentIndex] = data?.data?.lastPage ?? 1
                
                if self.collectionCurrentIndex < self.collectionTitles.count-1 {
                    self.collectionCurrentIndex += 1
                    self.setupCategory()
                    self.callAllCollectionAPI()
                    
                } else {
                    if let category = self.categoryFromMenu {
                        self.segmentControl.selectedSegmentIndex = category
                        self.categoryFromMenu = nil
                    }
                    
                    self.noData = self.productList?[self.currentSelectedIndex].count ?? 0 > 0 ? false : true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func callSingleCollectionAPI() {
        productViewModel.getProductList(page: apiCollectionPage?[currentSelectedIndex], sortBy: selectedSortByList?[currentSelectedIndex], categoryId: selectedCategoryIdList?[currentSelectedIndex], filter: selectedFilterList?[currentSelectedIndex]) { (proceed, data) in
            
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.productList?[self.currentSelectedIndex].append(contentsOf: data?.data?.products ?? [])
                self.apiCollectionPage?[self.currentSelectedIndex] = data?.data?.currentPage ?? 1
                self.apiCollectionTotalPage?[self.currentSelectedIndex] = data?.data?.lastPage ?? 1
                self.noData = self.productList?[self.currentSelectedIndex].count ?? 0 > 0 ? false : true
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func segmentSelected(sender: ScrollableSegmentedControl) {
        currentSelectedIndex = sender.selectedSegmentIndex
        UIView.animate(withDuration: 0.2) {
            self.stackView.subviews[1].isHidden = self.selectionList[self.currentSelectedIndex]?.children?.count ?? 0 <= 0
            self.lbCategory.text = self.selectedCategoryNameList?[self.currentSelectedIndex]
            self.noData = self.productList?[self.currentSelectedIndex].count ?? 0 > 0 ? false : true
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK:- NavBar Handlers
    @IBAction func menuHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func liveHandler(_ sender: Any) {
        enterFbLive()
    }
    
    @IBAction func cartHandler(_ sender: Any) {
        navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
    }

    
    //MARK:- Filter Handlers
    @IBAction func allCollectionsHandler(_ sender: Any) {
        let crystalsVC = getVC(sb: "Sheet", vc: "CrystalsVC") as! CrystalsVC
        crystalsVC.titles = self.selectionList[self.currentSelectedIndex]?.children
        let header: CGFloat = 160
        let rowCount = (self.selectionList[self.currentSelectedIndex]?.children?.count ?? 0)
        let rowHeight: CGFloat = 80 * CGFloat(rowCount/2).rounded(.up)
        let btmPadding: CGFloat = hasTopNotch ? 48 : 0
        
        getSheetedController(controller: crystalsVC, sizes: [.fixed(header+rowHeight+btmPadding)], currentVC: self) { (sc) in
            let crystalsVC = sc as! CrystalsVC
            if let id = crystalsVC.selectedCategory?.id, let name = crystalsVC.selectedCategory?.name {
                self.selectedCategoryIdList?[self.currentSelectedIndex] = "\(id)"
                self.selectedCategoryNameList?[self.currentSelectedIndex] = name
            }
            self.productList?[self.currentSelectedIndex] = []
            self.callSingleCollectionAPI()
        }
    }
    
    @IBAction func sortHandler(_ sender: Any) {
        let sortVC = getVC(sb: "Sheet", vc: "SortVC") as! SortVC
        let header: CGFloat = 160
        let rowHeight: CGFloat = 36*4
        let btmPadding: CGFloat = hasTopNotch ? 48 : 0
        
        sortVC.selectedSortBy = self.selectedSortByList?[self.currentSelectedIndex] ?? ""
        getSheetedController(controller: sortVC, sizes: [.fixed(header+rowHeight+btmPadding)], currentVC: self) { (sc) in
            let sortVC = sc as! SortVC
            self.selectedSortByList?[self.currentSelectedIndex] = sortVC.selectedSortBy
            self.productList?[self.currentSelectedIndex] = []
            self.callSingleCollectionAPI()
        }
    }
    
    @IBAction func filterHandler(_ sender: Any) {
        let filterVC = getVC(sb: "Sheet", vc: "FilterVC") as! FilterVC
        filterVC.filterList = filterList
        
        let header: CGFloat = 160
        let containerHeight: CGFloat = 350
        let btmPadding: CGFloat = hasTopNotch ? 48 : 0
                
        getSheetedController(controller: filterVC, sizes: [.fixed(header+containerHeight+btmPadding)], currentVC: self) { (sc) in
            let filterVC = sc as! FilterVC
            self.selectedFilterList?[self.currentSelectedIndex] = filterVC.selectedList.joined(separator: ",")
            self.productList?[self.currentSelectedIndex] = []
            self.callSingleCollectionAPI()
        }
    }
}


extension ProductListingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noData ? 1 : productList?[currentSelectedIndex].count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if noData {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyDataCVC", for: indexPath) as! EmptyDataCVC
            cell.isUserInteractionEnabled = false
            cell.awakeFromNib()
            cell.lbMsg.text = kLb.coming_soon.localized
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listingCVC", for: indexPath) as! ListingCVC
        if let products = productList?[currentSelectedIndex][indexPath.row] {
            cell.tag = indexPath.row
            cell.delegate = self
            cell.ivProduct.loadWithCache(strUrl: products.imgPath)
            cell.lbPrice.text = (products.currencyCode ?? "") + (products.currentUnitPrice ?? "")
            cell.lbDesc.text = products.productName
            cell.vwBestSeller.isHidden = products.bestSeller ?? 0 == 0
            cell.isFav = products.isWishlist
            
            //Hide in online courses
            cell.btnFav.isHidden = (products.prdType ?? "") == ProductType.academy.rawValue
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if noData {
            let screenWidth = UIScreen.main.bounds.size.width
            return CGSize(width: screenWidth, height: screenWidth)
        }
        
        let sideMargin: CGFloat = 24*2
        let cellGap: CGFloat = 14
        let width = (UIScreen.main.bounds.width - sideMargin - cellGap)/2
        let height = width + 68
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 24, bottom: 38, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let products = productList?[currentSelectedIndex][indexPath.row] {
            productViewModel.getProductDetails(productId: products.id ?? 0) { (proceed, data) in
                if proceed {
                    let vc = getVC(sb: "Landing", vc: "ProductDetailsVC") as! ProductDetailsVC
                    if let data = data {
                        vc.productDetailsData = data
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let productList = productList, productList.indices.contains(currentSelectedIndex), productList[currentSelectedIndex].count != 0 {
            if indexPath.row == productList[currentSelectedIndex].count-1, apiCollectionPage?[currentSelectedIndex] != apiCollectionTotalPage?[currentSelectedIndex] {
                apiCollectionPage?[currentSelectedIndex] += 1
                callSingleCollectionAPI()
            }
        }
    }
}

extension ProductListingVC: ListingCVCDelegate {
    func updateWishlist(index: Int) {
        let data = productList?[currentSelectedIndex][index]
        if let prdMasterId = data?.id, let isFav = data?.isWishlist {
            profileViewModel.updateWishlist(prdMasterId: "\(prdMasterId)", isFav: isFav) { (proceed, data) in
                if proceed {
                    self.setupData()
                }
            }
        }
    }
}
