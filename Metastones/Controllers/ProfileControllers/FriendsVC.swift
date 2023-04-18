//
//  FriendsVC.swift
//  Metastones
//
//  Created by Sonya Hew on 29/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let profileViewModel = ProfileViewModel()
    let refresher = UIRefreshControl()
    
    var friendList: [FriendListDataModel?] = []
    var noData : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
        
        lbTitle.text = kLb.my_friends.localized.capitalized
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionFooterHeight = 0
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2000))
        footer.backgroundColor = .white
        tableView.tableFooterView = footer
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -2000, right: 0)
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
    }
    
    @objc func refreshData() {
           setupData()
       }
       
       func setupData() {
           profileViewModel.getFriendList { (proceed, data) in
               if self.refresher.isRefreshing {
                   self.refresher.endRefreshing()
               }
               
               if proceed {
                   self.friendList = data?.data ?? []
                   self.noData = self.friendList.count > 0 ? false : true
                   self.tableView.reloadData()
               }
           }
       }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension FriendsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsTVC") as! FriendsTVC
        let data = friendList[indexPath.row]
        cell.selectionStyle = .none
        cell.ivPhoto.loadWithCache(strUrl: data?.imgPath ?? "", placeholder: #imageLiteral(resourceName: "account-img-profile-defualt.png"))
        cell.lbMemId1.text = "\(kLb.member_name.localized): \(data?.name ?? "")"
        cell.lbMemId2.text = data?.contactDesc ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
}

//MARK:- FriendsTVC
class FriendsTVC: UITableViewCell {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbMemId1: UILabel!
    @IBOutlet weak var lbMemId2: UILabel!
    
    override func awakeFromNib() {
        ivPhoto.backgroundColor = .clear
        ivPhoto.applyCornerRadius(cornerRadius: 20)
    }
}
