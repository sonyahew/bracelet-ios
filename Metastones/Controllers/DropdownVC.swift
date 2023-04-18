//
//  DropdownVC.swift
//  Metastones
//
//  Created by Sonya Hew on 20/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class DropdownVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tvDropDown: UITableView!
    
    var strTitle: String? = ""
    var selections: [(selection: String, image: String?)] = []
    
    var selectedIndex: Int?
    var selectedValue: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvDropDown.dataSource = self
        tvDropDown.delegate = self
        tvDropDown.register(LandingTVHC.self, forHeaderFooterViewReuseIdentifier: "landingTVHC")
        tvDropDown.register(UINib(nibName: "DropdownTVC", bundle: Bundle.main), forCellReuseIdentifier: "dropdownTVC")
        tvDropDown.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 6))
        tvDropDown.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func doneHandler(_ sender: Any) {
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
    }
}

extension DropdownVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return strTitle != "" ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "landingTVHC") as! LandingTVHC
        header.lbTitle.text = strTitle
        header.contentView.backgroundColor = .white
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownTVC") as! DropdownTVC
        cell.strImage = selections[indexPath.row].image
        cell.strText = selections[indexPath.row].selection
        cell.awakeFromNib()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectedValue = selections[indexPath.row].selection
        tableView.deselectRow(at: indexPath, animated: true)
        self.sheetViewController?.dismiss(animated: true)
    }
}


protocol LandingTVHCDelegate: class {
    func didTapBtnMore(index: Int)
}

class LandingTVHC: UITableViewHeaderFooterView {
    
    weak var delegate : LandingTVHCDelegate?
    
    let lbTitle: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 17)
        lb.textColor = UIColor(hex: 0x2E2E2E)
        return lb
    }()
        
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(hex: 0xF7F7F7)
        clipsToBounds = false

        contentView.addSubview(lbTitle)
        lbTitle.translatesAutoresizingMaskIntoConstraints = false
        lbTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18).isActive = true
        lbTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

