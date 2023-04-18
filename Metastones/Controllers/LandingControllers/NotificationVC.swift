//
//  NotificationVC.swift
//  Metastones
//
//  Created by Sonya Hew on 15/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let refresher = UIRefreshControl()
    let viewModel = ViewModelBase()
    let popupManager = PopupManager.shared
    
    var notifications : [NotificationSubdataModel?] = []
    var currentPage : Int = 1
    var totalPage : Int = 1
    var noData : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
        
        lbTitle.text = kLb.notifications.localized.capitalized
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionFooterHeight = 0.01
        tableView.sectionHeaderHeight = 0.01
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
        tableView.isHidden = true
    }
    
    func setupData() {
        viewModel.getNotification(page: currentPage) { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            if self.tableView.isHidden {
                self.tableView.isHidden = false
            }
            
            if proceed {
                self.totalPage = data?.data?.lastPage ?? 1
                self.notifications.append(contentsOf: data?.data?.notification ?? [])
                self.noData = self.notifications.count == 0
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshData() {
           noData = true
           currentPage = 1
           totalPage = 1
           notifications = []
           setupData()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationTVC") as! NotificationTVC
        let data = notifications[indexPath.row]
        cell.lbTitle.text = data?.title
        cell.lbDesc.text = data?.desc
        cell.lbDate.text = data?.dateAdded
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let noti = notifications[indexPath.row] {
            popupManager.showAlert(destVC: popupManager.getNotiPopup(title: noti.title ?? "", desc: noti.desc ?? ""))
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if notifications.count != 0 {
            if indexPath.item == notifications.count-1, currentPage != totalPage {
                currentPage += 1
                setupData()
            }
        }
    }
}

//MARK:- NotificationTVC
class NotificationTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    override func awakeFromNib() {
    }
}
