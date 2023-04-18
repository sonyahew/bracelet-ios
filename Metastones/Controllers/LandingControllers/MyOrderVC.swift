//
//  MyOrderVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class MyOrderVC: UIViewController {
    
    weak var delegate: MenuDelegate?
    let appData = AppData.shared
    let cartViewModel = CartViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    
    //segment
    @IBOutlet weak var segmentContainer: UIView!
    let segmentControl = ScrollableSegmentedControl()
    let profileViewModel = ProfileViewModel()

    var currentSelectedIndex: Int = 0
    var statusCurrentIndex: Int = 0
    var selectedStatus: String = ""
    var noData : Bool = true
    
    private var segmentTitles = [kLb.all.localized, kLb.to_confirm.localized, kLb.to_ship.localized, kLb.received.localized, kLb.completed.localized]

    let segmentImgs = [#imageLiteral(resourceName: "icon-order-all-on.png"), #imageLiteral(resourceName: "icon-order-confirm-on"), #imageLiteral(resourceName: "icon-order-shipping-on"), #imageLiteral(resourceName: "icon-order-receive-on"), #imageLiteral(resourceName: "icon-order-completed-on")]
    private var apiStatusType = ["", "CFM", "S", "RCV", "COM"]
    private var apiHistoryPage : [Int]? = []
    private var apiHistoryTotalPage : [Int]? = []
    private var orderHistory : [[OrderHistorySubdataModel?]] = []
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.my_orders.localized.capitalized
        
        setupSegmentView()
        setupTableView()
        setupData()
    }
    
    func setupSegmentView() {
        //add segments here
        for (index, title) in segmentTitles.enumerated() {
            segmentControl.insertSegment(withTitle: title, image: segmentImgs[index], at: index)
        }
        segmentControl.segmentStyle = .imageOnLeft
        segmentControl.underlineSelected = true
        segmentControl.fixedSegmentWidth = true
        segmentControl.segmentContentColor = .msBrown
        segmentControl.selectedSegmentContentColor = UIColor(hex: 0x1D2236)
        segmentControl.tintColor = UIColor(hex: 0x1D2236)
        segmentControl.selectedSegmentIndex = currentSelectedIndex
        segmentControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        segmentContainer.addSubviewAndPinEdges(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 2).isActive = true
        segmentControl.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 2).isActive = true
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionFooterHeight = 0.1
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2000))
        footer.backgroundColor = .white
        tableView.tableFooterView = footer
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -2000, right: 0)
        tableView.register(UINib(nibName: "OrderListTVC", bundle: Bundle.main), forCellReuseIdentifier: "orderListTVC")
        tableView.register(UINib(nibName: "OrderListTVHC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "orderListTVHC")
        tableView.register(UINib(nibName: "OrderListTVFC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "orderListTVFC")
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
        tableView.isHidden = true
    }
    
    func setupData() {
        statusCurrentIndex = 0
        apiHistoryPage = []
        apiHistoryTotalPage = []
        orderHistory = []
        
        for _ in apiStatusType {
            apiHistoryPage?.append(1)
            apiHistoryTotalPage?.append(1)
            orderHistory.append([])
        }
        
        callAllOrderHistoryAPI()
    }
    
    func callAllOrderHistoryAPI() {
        profileViewModel.getOrderList(status: apiStatusType[statusCurrentIndex], page: String(format:"%d", apiHistoryPage?[statusCurrentIndex] ?? 0)) { (proceed, data) in
            
            if self.tableView.isHidden {
                self.tableView.isHidden = false
            }
            
            if proceed {
                self.orderHistory[self.statusCurrentIndex] = data?.data?.transaction ?? []
                self.apiHistoryPage?[self.statusCurrentIndex] = data?.data?.currentPage ?? 1
                self.apiHistoryTotalPage?[self.statusCurrentIndex] = data?.data?.lastPage ?? 1
                
                if self.statusCurrentIndex < self.apiStatusType.count-1 {
                    self.statusCurrentIndex += 1
                    self.callAllOrderHistoryAPI()
                } else {
                    self.noData = self.orderHistory[self.currentSelectedIndex].count > 0 ? false : true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func callSingleWalletTrxAPI() {
        profileViewModel.getOrderList(status: apiStatusType[currentSelectedIndex], page: String(format:"%d", apiHistoryPage?[currentSelectedIndex] ?? 0)) { (proceed, data) in
            
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.orderHistory[self.currentSelectedIndex].append(contentsOf: data?.data?.transaction ?? [])
                self.apiHistoryPage?[self.currentSelectedIndex] = data?.data?.currentPage ?? 1
                self.apiHistoryTotalPage?[self.currentSelectedIndex] = data?.data?.lastPage ?? 1
                self.noData = self.orderHistory[self.currentSelectedIndex].count > 0 ? false : true
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshData() {
        apiHistoryPage?[currentSelectedIndex] = 1
        apiHistoryTotalPage?[currentSelectedIndex] = 1
        orderHistory[self.currentSelectedIndex] = []
        callSingleWalletTrxAPI()
    }
    
    @objc func segmentSelected(sender: ScrollableSegmentedControl) {
        currentSelectedIndex = sender.selectedSegmentIndex
        self.noData = orderHistory[currentSelectedIndex].count > 0 ? false : true
        tableView.reloadData()
    }
    
    
    //MARK:- NavBar Handlers
    @IBAction func menuHandler(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cartHandler(_ sender: Any) {
        if isMemberUser(vc: self.navigationController) {
            navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
        }
    }
       
    @IBAction func qrHandler(_ sender: Any) {
           navigationController?.pushViewController(getVC(sb: "Landing", vc: "NotificationVC"), animated: true)
    }
}

extension MyOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return noData ? 1 : orderHistory[currentSelectedIndex].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : orderHistory[currentSelectedIndex][section]?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if orderHistory[currentSelectedIndex].count == 0 {
            return UIView()
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "orderListTVHC") as! OrderListTVHC
        let data = orderHistory[currentSelectedIndex][section]
        header.orderNo = data?.docNo ?? ""
        header.status = "" // data?.shipAddrName
        header.orderDate = data?.displayDate ?? ""
        header.paidDate = ""
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return noData ? 0.01 : 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderListTVC") as! OrderListTVC
        let data = orderHistory[currentSelectedIndex][indexPath.section]?.items[indexPath.row]
        cell.selectionStyle = .none
        cell.ivProduct.loadWithCache(strUrl: data?.imgPath)
        cell.title = "\(data?.productName ?? "")\n\((data?.optionName ?? []).joined(separator: "\n"))"
        cell.price = " "
        cell.qty = " "
//        cell.price = "\(data?.currencyCode ?? "") \(data?.unitPrice?.toDisplayCurrency() ?? "")"
//        if let qty = data?.qty {
//            cell.qty = "\(kLb.quantity.localized): \(qty)"
//        } else {
//            cell.qty = ""
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderDetailsVC = getVC(sb: "Landing", vc: "OrderDetailsVC") as! OrderDetailsVC
        orderDetailsVC.data = orderHistory[currentSelectedIndex][indexPath.section]
        orderDetailsVC.selectedIndex = indexPath.row
        navigationController?.pushViewController(orderDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if orderHistory[currentSelectedIndex].count == 0 {
            return UIView()
        }
        
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "orderListTVFC") as! OrderListTVFC
        let data = orderHistory[currentSelectedIndex][section]
        footer.btnStatus.setTitle(data?.statusDesc?.localized, for: .normal)
        if let totalQty = data?.items.count, let currencyCode = data?.items.first??.currencyCode, let subtotal = data?.subtotal {
            footer.lbPrice.attributedText = setupTotal(label: "\(totalQty) \(kLb.items.localized), \(kLb.total.localized)", value: "\(currencyCode) \(subtotal.toDisplayCurrency())")
        }
        footer.awakeFromNib()
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return noData ? 0.01 : 72
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if orderHistory[currentSelectedIndex].count != 0 {
            if indexPath.section == orderHistory[currentSelectedIndex].count - 1, apiHistoryPage?[currentSelectedIndex] != apiHistoryTotalPage?[currentSelectedIndex] {
                apiHistoryPage?[currentSelectedIndex] += 1
                callSingleWalletTrxAPI()
            }
        }
    }
}
