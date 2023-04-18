//
//  MyAddressesVC.swift
//  Metastones
//
//  Created by Sonya Hew on 30/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum AddressListType {
    case edit
    case select
}

class MyAddressesVC: UIViewController {
    
    let appData = AppData.shared
    let profileViewModel = ProfileViewModel()

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbAddAddress: UILabel!
    
    var addressType: AddressType = .billing
    var addressListType: AddressListType = .edit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        lbTitle.text = kLb.my_addresses.localized.capitalized
        lbAddAddress.text = kLb.add_new_address.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionFooterHeight = 0.01
        tableView.sectionHeaderHeight = 0.01
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewAddressHandler(_ sender: Any) {
        let editVC = getVC(sb: "Profile", vc: "AddAddressVC") as! AddAddressVC
        editVC.editAddress = .add
        navigationController?.pushViewController(editVC, animated: true)
    }
}

extension MyAddressesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appData.profile?.addr.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressListTVC") as! AddressListTVC
        var strAddr = ""
        if let addr = appData.profile?.addr[indexPath.row] {
            cell.lbName.text = addr.displayAddrName
            strAddr.append("\(addr.mobileNo ?? "")\n")
            strAddr.append("\(addr.addr1 ?? "")\n")
            strAddr.append("\(addr.cityDesc ?? ""), ")
            strAddr.append("\(addr.stateDesc ?? "")\n")
            strAddr.append("\(addr.countryDesc ?? "")")
        }
        cell.lbAddress.text = strAddr
        cell.selectionStyle = .none
        
        if addressType == .billing {
            cell.btnDefault.isHidden = appData.profile?.addr[indexPath.row]?.defaultBilling != 1
            
        } else {
            cell.btnDefault.isHidden = appData.profile?.addr[indexPath.row]?.defaultShipping != 1
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if addressListType == .select {
            let data = appData.profile?.addr[indexPath.row]
            profileViewModel.updateAddress(category: "UPDATE", addressId: data?.id, addrType: EditAddressType.shipping.rawValue) { (proceed, data) in
                if proceed {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            let addAddrVC = getVC(sb: "Profile", vc: "AddAddressVC") as! AddAddressVC
            addAddrVC.addrIndex = indexPath.row
            addAddrVC.editAddress = .edit
            navigationController?.pushViewController(addAddrVC, animated: true)
        }
    }
}

//MARK:- AddressListTVC
class AddressListTVC: UITableViewCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var btnDefault: UIButton!
    
    override func awakeFromNib() {
        btnDefault.applyCornerRadius(cornerRadius: 10)
        btnDefault.setTitle(kLb._default.localized, for: .normal)
    }
}
