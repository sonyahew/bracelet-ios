//
//  PersonalizedCartVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 26/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum PersonalizedCartAction {
    case addToCart
    case viewCart
    case continueCustom
}

class PersonalizedCartVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbTotalValue: UILabel!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnViewCart: BrownButton!
    @IBOutlet weak var btnContinue: ReversedBrownButton!
    
    var totalQty: String? = ""
    var totalAmt: String? = ""
    var dragItemObjList: [BraceletBeadModel?] = []
    var mergedDragItemObjList: [BraceletBeadModel?] = []
    
    var cartAction: PersonalizedCartAction = .continueCustom
    var isAddedCart: Bool = false
    var enableBtnCart: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.selected_components.localized
        lbTotal.text = "\(kLb.total.localized):"
        lbTotalValue.text = totalAmt
        btnAddToCart.setTitle(kLb.add_to_cart.localized, for: .normal)
        btnAddToCart.applyCornerRadius(cornerRadius: btnAddToCart.frame.size.height/2)
        
        btnViewCart.setTitle(kLb.view_cart.localized, for: .normal)
        btnViewCart.applyCornerRadius(cornerRadius: btnViewCart.frame.size.height/2)
        btnContinue.setTitle(kLb._continue.localized, for: .normal)
        btnContinue.applyCornerRadius(cornerRadius: btnContinue.frame.size.height/2)
        
        btnAddToCart.isUserInteractionEnabled = enableBtnCart
        btnAddToCart.alpha = enableBtnCart ? 1 : 0.5
        
        btnViewCart.isHidden = !isAddedCart
        btnContinue.isHidden = !isAddedCart
        btnAddToCart.isHidden = isAddedCart
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "OrderListTVC", bundle: Bundle.main), forCellReuseIdentifier: "orderListTVC")
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
        
        for item in dragItemObjList {
            if mergedDragItemObjList.filter({ $0?.id == item?.id }).count > 0, let index = mergedDragItemObjList.firstIndex(where: { $0?.id == item?.id }) {
                mergedDragItemObjList[index]?.quantity += 1
            } else {
                mergedDragItemObjList.append(item)
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addToCartHandler(_ sender: Any) {
        cartAction = .addToCart
        self.sheetViewController?.dismiss(animated: true)
    }
    
    @IBAction func viewCartHandler(_ sender: Any) {
        cartAction = .viewCart
        self.sheetViewController?.dismiss(animated: true)
    }
    
    @IBAction func continueHandler(_ sender: Any) {
        cartAction = .continueCustom
        self.sheetViewController?.dismiss(animated: true)
    }
}

extension PersonalizedCartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mergedDragItemObjList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderListTVC") as! OrderListTVC
        cell.selectionStyle = .none
        cell.ivProduct.backgroundColor = .clear
        
        let data = mergedDragItemObjList[indexPath.row]
        cell.ivProduct.loadWithCache(strUrl: data?.path)
        cell.title = "\(data?.name ?? "")"
        cell.price = "\(data?.currencyCode ?? "")\("\(data?.unitPrice ?? "")".toDisplayCurrency())"
        cell.qty = "\(kLb.quantity.localized): \(data?.quantity ?? 0)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
