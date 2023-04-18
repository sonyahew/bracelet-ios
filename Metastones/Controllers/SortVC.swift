//
//  SortVC.swift
//  Metastones
//
//  Created by Sonya Hew on 05/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class SortVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let titles: [(title: String, value: String)] = [
                                                    (kLb.price_asc.localized, "PRICE_ASC"),
                                                    (kLb.price_desc.localized, "PRICE_DESC"),
                                                    (kLb.name_asc.localized, "AZ_ASC"),
                                                    (kLb.name_desc.localized, "AZ_DESC")
                                                    ]
    
    var selectedSortBy: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.sort.localized
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
    }
}

extension SortVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "radioTVC", for: indexPath) as! RadioTVC
        cell.selectionStyle = .none
        cell.lbTitle.text = titles[indexPath.row].title
        cell.setupAs(isSelected: indexPath.row == titles.indices.filter({ titles[$0].value == selectedSortBy }).first ? true : false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RadioTVC
        cell.setupAs(isSelected: true)
        selectedSortBy = titles[indexPath.row].value
        DispatchQueue.main.async {
            self.sheetViewController?.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RadioTVC
        cell.setupAs(isSelected: false)
    }
}

//MARK:- RadioTVC
class RadioTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnRadio: UIButton!
    
    override func awakeFromNib() {
    }
    
    func setupAs(isSelected: Bool) {
        btnRadio.isSelected = isSelected
    }
}
