//
//  FavouriteListVC.swift
//  Metastones
//
//  Created by Sonya Hew on 29/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class FavouriteListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    
    let popupManager = PopupManager.shared
    let profileViewModel = ProfileViewModel()
    let refresher = UIRefreshControl()
    let homeViewModel = HomeViewModel()
    
    var baziList: [BaziBookDataModel?] = []
    var noData : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupData()
        
        lbTitle.text = kLb.bazi_book_lists.localized.capitalized
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
        profileViewModel.getBaziList { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.baziList = data?.data ?? []
                self.noData = self.baziList.count > 0 ? false : true
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension FavouriteListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : self.baziList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteTVC") as! FavouriteTVC
        let data = baziList[indexPath.row]
        cell.selectionStyle = .none
        cell.lbName.text = data?.name ?? " "
        cell.lbDOB.text = data?.birthDate ?? " "
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = baziList[indexPath.row]
        let birthDateWithHour = data?.birthDate?.toDate(fromFormat: "dd/MM/yyyy HH:mm:ss")
        let birthDate = data?.birthDate?.toDate(fromFormat: "dd/MM/yyyy")
        let dobStr = "\(data?.name ?? "")\n\(data?.birthDate ?? "")\n"
        
        if let validBirthDateWithHour = birthDateWithHour {
            homeViewModel.calculateBazi(year: validBirthDateWithHour.year, month: validBirthDateWithHour.month, day: validBirthDateWithHour.day, hour: validBirthDateWithHour.hour, gender: data?.gender) { (proceed, data) in
                if proceed {
                    let colorBalanceVC = getVC(sb: "Landing", vc: "ColorBalanceVC") as! ColorBalanceVC
                    colorBalanceVC.bzData = data?.data
                    colorBalanceVC.userNameDOB = dobStr
                    self.navigationController?.pushViewController(colorBalanceVC, animated: true)
                }
            }
            
        } else if let validBirthDate = birthDate {
            homeViewModel.calculateBazi(year: validBirthDate.year, month: validBirthDate.month, day: validBirthDate.day, gender: data?.gender) { (proceed, data) in
                if proceed {
                    let colorBalanceVC = getVC(sb: "Landing", vc: "ColorBalanceVC") as! ColorBalanceVC
                    colorBalanceVC.bzData = data?.data
                    colorBalanceVC.userNameDOB = dobStr
                    self.navigationController?.pushViewController(colorBalanceVC, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                           trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
          let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                    if let bazi = self.baziList[indexPath.row], let defaultBz = bazi.defaultBz, defaultBz == 0 {
                        self.profileViewModel.removeBazi(baziId: self.baziList[indexPath.row]?.id) { (proceed, data) in
                            if proceed {
                                tableView.beginUpdates()
                                self.baziList.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .automatic)
                                tableView.endUpdates()
                            }
                        }
                    } else {
                        self.popupManager.showAlert(destVC: self.popupManager.getAlertPopup(desc: kLb.default_bazi_unable_to_delete.localized))
                    }
            
                    success(true)
          })
        deleteAction.image = #imageLiteral(resourceName: "icon_delete")
        deleteAction.backgroundColor = .red

          return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            profileViewModel.removeBazi(baziId: baziList[indexPath.row]?.id) { (proceed, data) in
                if proceed {
                    tableView.beginUpdates()
                    self.baziList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
        }
    }
}

//MARK:- FavouriteTVC
class FavouriteTVC: UITableViewCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDOB: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        btnDelete.isUserInteractionEnabled = false
    }
    
    @IBAction func deleteHandler(_ sender: Any) {
    }
}
