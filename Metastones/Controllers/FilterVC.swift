//
//  FilterVC.swift
//  Metastones
//
//  Created by Sonya Hew on 05/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

@objc protocol FilterDelegate {
    func didTapHeader(section: Int)
}

class FilterVC: UIViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnView: BrownButton!
    
    var filterList: [PrdFilterDataModel?] = []
    var selectedList: [String] = []
    
    var isExpanded : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.filters.localized
        btnClear.setTitle(kLb.clear.localized, for: .normal)
        btnView.setTitle(kLb.view.localized, for: .normal)
        isExpanded = [Bool](repeatElement(false, count: filterList.count))
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FilterTVC", bundle: Bundle.main), forCellReuseIdentifier: "filterTVC")
        tableView.register(UINib(nibName: "FilterTVHC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "filterTVHC")
        tableView.separatorColor = #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)
    }
    
    @IBAction func clearHandler(_ sender: Any) {
        selectedList = []
        tableView.reloadData()
    }
    
    @IBAction func viewHandler(_ sender: Any) {
        self.sheetViewController?.dismiss(animated: true)
    }
}

extension FilterVC: FilterDelegate {
    func didTapHeader(section: Int) {
        isExpanded[section] = !isExpanded[section]
        let header = tableView.headerView(forSection: section) as! FilterTVHC
        header.lbExpansion.text = isExpanded[section] ? "-" : "+"
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension FilterVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList[section]?.optValue.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "filterTVHC") as! FilterTVHC
        header.delegate = self
        header.tag = section
        header.lbTitle.text = filterList[section]?.optName?.localized
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterTVC", for: indexPath) as! FilterTVC
        cell.selectionStyle = .none
        cell.lbTitle.text = filterList[indexPath.section]?.optValue[indexPath.row]?.optChoice
        if let code = filterList[indexPath.section]?.optValue[indexPath.row]?.code, selectedList.contains(code) {
            cell.btnCheck.isSelected = true
        } else {
            cell.btnCheck.isSelected = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded[indexPath.section] {
            return 56
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FilterTVC
        if let selectedCode = filterList[indexPath.section]?.optValue[indexPath.row]?.code, !selectedList.contains(selectedCode) {
            selectedList.append(selectedCode)
        }
        cell.toggleSelected()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FilterTVC
        if let selectedCode = filterList[indexPath.section]?.optValue[indexPath.row]?.code, selectedList.contains(selectedCode), let index = selectedList.firstIndex(of: selectedCode) {
            selectedList.remove(at: index)
        }
        cell.toggleSelected()
    }
}
