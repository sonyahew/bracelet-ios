//
//  MyWithdrawalVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 06/01/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit

class MyWithdrawalVC: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let profileViewModel = ProfileViewModel()
    let popupManager = PopupManager.shared
    
    var noData : Bool = true
    
    private var apiWithdrawalTrxPage : Int = 1
    private var apiWithdrawalTrxTotalPage : Int = 0
    private var withdrawalTransaction : [MyWithdrawalSubdataModel?] = []
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
        
        lbTitle.text = kLb.my_withdrawal.localized.capitalized
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
        apiWithdrawalTrxPage = 1
        apiWithdrawalTrxTotalPage = 0
        withdrawalTransaction = []
        
        callWithdrawalTrxAPI()
    }
    
    func callWithdrawalTrxAPI() {
        profileViewModel.withdrawalList(page: apiWithdrawalTrxPage) { (proceed, data) in
            if proceed {
                if self.tableView.isHidden {
                    self.tableView.isHidden = false
                }
                if self.refresher.isRefreshing {
                    self.refresher.endRefreshing()
                }
                
                if proceed {
                    self.withdrawalTransaction.append(contentsOf: data?.data?.withdrawals ?? [])
                    self.apiWithdrawalTrxPage = data?.data?.currentPage ?? 1
                    self.apiWithdrawalTrxTotalPage = data?.data?.lastPage ?? 1
                    
                    self.noData = self.withdrawalTransaction.count > 0 ? false : true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func refreshData() {
        apiWithdrawalTrxPage = 1
        apiWithdrawalTrxTotalPage = 1
        withdrawalTransaction = []
        callWithdrawalTrxAPI()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension MyWithdrawalVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : withdrawalTransaction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWithdrawalTVC", for: indexPath) as! MyWithdrawalTVC
        let data = withdrawalTransaction[indexPath.row]
        cell.lbDate.text = data?.transDate
        if let docNo = data?.docNo {
            cell.lbTrxNo.text = "\(docNo)"
        } else {
            cell.lbTrxNo.text = ""
        }
        cell.lbTrxName.text = data?.bankName ?? " "
        cell.lbStatus.text = data?.statusDesc
        cell.setStatusColor(forStatus: data?.status ?? "")
        cell.lbRate.text = data?.totalAmount
        cell.btnCancel.isHidden = data?.status ?? "" != WithdrawalTrxStatus.pending.rawValue
        cell.tag = data?.id ?? 0
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if withdrawalTransaction.count != 0 {
            if indexPath.row == withdrawalTransaction.count - 1, apiWithdrawalTrxPage != apiWithdrawalTrxTotalPage {
                apiWithdrawalTrxPage += 1
                callWithdrawalTrxAPI()
            }
        }
    }
}

extension MyWithdrawalVC: MyWithdrawalTVCDelegate {
    func tapCancel(id: Int) {
        popupManager.showAlert(destVC: popupManager.getGeneralPopup(title: "", desc: kLb.are_you_sure_to_cancel_this_withdrawal.localized, strLeftText: kLb.ok.localized, strRightText: kLb.cancel.localized, style: .warning, isShowSingleBtn: false, isShowNoBtn: false)) { (btnTitle) in
            if btnTitle == kLb.ok.localized {
                self.profileViewModel.updateWithdrawal(withdrawalId: id) { (proceed, data) in
                    if proceed {
                        self.refreshData()
                    }
                }
            }
        }
    }
}


//MARK:- TrxTVC

enum WithdrawalTrxStatus: String {
    case approve = "AP"
    case cancel = "C"
    case pending = "P"
    case rejected = "R"
}

protocol MyWithdrawalTVCDelegate: class {
    func tapCancel(id: Int)
}

class MyWithdrawalTVC: UITableViewCell {
    
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTrxNo: UILabel!
    @IBOutlet weak var lbTrxName: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbRate: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    weak var delegate: MyWithdrawalTVCDelegate?
    
    override func awakeFromNib() {
    }
    
    func setStatusColor(forStatus status: String) {
        switch status {
        case WithdrawalTrxStatus.approve.rawValue:
            setStatus(withTitle: kLb.completed.localized, color: UIColor(hex: 0x00A834))
            
        case WithdrawalTrxStatus.cancel.rawValue:
            setStatus(withTitle: kLb.cancel.localized, color: UIColor(hex: 0xFA4F4F))
            
        case WithdrawalTrxStatus.pending.rawValue:
            setStatus(withTitle: kLb.pending.localized, color: UIColor(hex: 0xFF7F00))
            
        case WithdrawalTrxStatus.rejected.rawValue:
            setStatus(withTitle: kLb.rejected.localized, color: UIColor(hex: 0xFA4F4F))
            
        default:
            setStatus(withTitle: "", color: UIColor.black)
        }
    }
    
    private func setStatus(withTitle title: String, color: UIColor) {
        lbStatus.text = title
        lbStatus.textColor = color
        lbRate.textColor = .black
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        delegate?.tapCancel(id: self.tag)
    }
}
