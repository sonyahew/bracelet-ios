//
//  TransactionsVC.swift
//  Metastones
//
//  Created by Sonya Hew on 31/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class TransactionsVC: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentContainer: UIView!
    
    let segmentControl = ScrollableSegmentedControl()
    let profileViewModel = ProfileViewModel()
    
    let collectionTitles: [(title: String, value: eWalletCode)] = [(kLb.meta_points.localized, .metaPoint), (kLb.meta_coins.localized, .metaCoin)]
    var currentSelectedIndex: Int = 0
    var walletCurrentIndex: Int = 0
    var noData : Bool = true
    
    private var apiWalletTrxPage : [Int]? = []
    private var apiWalletTrxTotalPage : [Int]? = []
    private var walletTransaction : [[WalletTrxSubdataModel?]]? = []
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentView()
        setupTableView()
        setupData()
        
        lbTitle.text = kLb.my_transaction.localized.capitalized
    }
    
    func setupSegmentView() {
        //add segments here
        for (index, item) in collectionTitles.enumerated() {
            segmentControl.insertSegment(withTitle: item.title, at: index)
        }
        segmentControl.segmentStyle = .textOnly
        segmentControl.underlineSelected = true
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
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionHeaderHeight = 0.01
        tableView.sectionFooterHeight = 0.01
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
        tableView.isHidden = true
    }
    
    func setupData() {
        walletCurrentIndex = 0
        apiWalletTrxPage = []
        apiWalletTrxTotalPage = []
        walletTransaction = []
        
        for _ in collectionTitles {
            apiWalletTrxPage?.append(1)
            apiWalletTrxTotalPage?.append(1)
            walletTransaction?.append([])
        }
        
        callAllWalletTrxAPI()
    }
    
    func callAllWalletTrxAPI() {
        profileViewModel.getWalletTrxList(ewalletType: collectionTitles[walletCurrentIndex].value.rawValue, page: apiWalletTrxPage?[walletCurrentIndex]) { (proceed, data) in
            if self.tableView.isHidden {
                self.tableView.isHidden = false
            }
            
            if proceed {
                self.walletTransaction?[self.walletCurrentIndex] = data?.data?.transaction ?? []
                self.apiWalletTrxPage?[self.walletCurrentIndex] = data?.data?.currentPage ?? 1
                self.apiWalletTrxTotalPage?[self.walletCurrentIndex] = data?.data?.lastPage ?? 1
                
                if self.walletCurrentIndex < self.collectionTitles.count-1 {
                    self.walletCurrentIndex += 1
                    self.callAllWalletTrxAPI()
                } else {
                    self.noData = self.walletTransaction?[self.currentSelectedIndex].count ?? 0 > 0 ? false : true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func callSingleWalletTrxAPI() {
        profileViewModel.getWalletTrxList(ewalletType: collectionTitles[currentSelectedIndex].value.rawValue, page: apiWalletTrxPage?[currentSelectedIndex]) { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.walletTransaction?[self.currentSelectedIndex].append(contentsOf: data?.data?.transaction ?? [])
                self.apiWalletTrxPage?[self.currentSelectedIndex] = data?.data?.currentPage ?? 1
                self.apiWalletTrxTotalPage?[self.currentSelectedIndex] = data?.data?.lastPage ?? 1
                self.noData = self.walletTransaction?[self.currentSelectedIndex].count ?? 0 > 0 ? false : true
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshData() {
        apiWalletTrxPage?[currentSelectedIndex] = 1
        apiWalletTrxTotalPage?[currentSelectedIndex] = 1
        walletTransaction?[self.currentSelectedIndex] = []
        callSingleWalletTrxAPI()
    }
    
    @objc func segmentSelected(sender: ScrollableSegmentedControl) {
        currentSelectedIndex = sender.selectedSegmentIndex
        self.noData = walletTransaction?[currentSelectedIndex].count ?? 0 > 0 ? false : true
        tableView.reloadData()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension TransactionsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : walletTransaction?[currentSelectedIndex].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "trxTVC", for: indexPath) as! TrxTVC
        let data = walletTransaction?[currentSelectedIndex][indexPath.row]
        cell.lbDate.text = data?.transDate
        if let docNo = data?.docNo {
            cell.lbTrxNo.text = "\(docNo)"
        } else {
            cell.lbTrxNo.text = ""
        }
        cell.lbTrxName.text = data?.description
        cell.lbStatus.text = ""
        cell.lbRate.text = data?.amountValue
        if let amount = data?.amountValue {
            cell.setRateColor(forStatus: amount.hasPrefix("-") ? .neg : .pos)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if walletTransaction?[currentSelectedIndex].count != 0 {
            if indexPath.item == (walletTransaction?[currentSelectedIndex].count ?? 0) - 1, apiWalletTrxPage?[currentSelectedIndex] != apiWalletTrxTotalPage?[currentSelectedIndex] {
                apiWalletTrxPage?[currentSelectedIndex] += 1
                callSingleWalletTrxAPI()
            }
        }
    }
}


//MARK:- TrxTVC

enum TrxStatus {
    case completed
    case pending
    case rejected
}

enum RateStatus {
    case pos
    case neg
    case normal
}

class TrxTVC: UITableViewCell {
    
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTrxNo: UILabel!
    @IBOutlet weak var lbTrxName: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbRate: UILabel!
    
    override func awakeFromNib() {
    }
    
    func setStatusColor(forStatus status: TrxStatus) {
        switch status {
        case .completed:
            setStatus(withTitle: kLb.completed.localized, color: UIColor(hex: 0x00A834))
        case .pending:
            setStatus(withTitle: kLb.pending.localized, color: UIColor(hex: 0xFF7F00))
        case .rejected:
            setStatus(withTitle: kLb.rejected.localized, color: UIColor(hex: 0xFA4F4F))
        }
    }
    
    func setRateColor(forStatus status: RateStatus) {
        switch status {
        case .pos:
            lbRate.textColor = UIColor(hex: 0x00A834)
        case .neg:
            lbRate.textColor = UIColor(hex: 0xFA4F4F)
        case .normal:
            lbRate.textColor = .black
        }
    }
    
    private func setStatus(withTitle title: String, color: UIColor) {
        lbStatus.text = title
        lbStatus.textColor = color
    }
}
