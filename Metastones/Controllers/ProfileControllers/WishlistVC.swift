//
//  WishlistVC.swift
//  Metastones
//
//  Created by Sonya Hew on 29/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class WishlistVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let refresher = UIRefreshControl()
    let profileViewModel = ProfileViewModel()
    let productViewModel = ProductViewModel()
    
    var wishlist : [WishlistDataModel?] = []
    var noData : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        lbTitle.text = kLb.my_wishlists.localized.capitalized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
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
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
        tableView.isHidden = true
    }
    
    func setupData() {
        profileViewModel.getWishlist { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            if self.tableView.isHidden {
                self.tableView.isHidden = false
            }
            
            if proceed {
                self.wishlist.append(contentsOf: data?.data ?? [])
                self.noData = self.wishlist.count == 0
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshData() {
           noData = true
           wishlist = []
           setupData()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension WishlistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noData ? 1 : wishlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistTVC") as! WishlistTVC
        let data = wishlist[indexPath.row]
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.delegate = self
        cell.ivProduct.backgroundColor = .clear
        cell.ivProduct.loadWithCache(strUrl: data?.imgPath)
        cell.lbProductName.text = data?.name
        cell.lbPrice.text = "\(data?.currencyCode ?? "")\(data?.minPrice?.toDisplayCurrency() ?? "") - \(data?.currencyCode ?? "")\(data?.maxPrice?.toDisplayCurrency() ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
}

extension WishlistVC: WishlistTVCDelegate{
    func deleteWishlist(index: Int) {
        let data = wishlist[index]
        if let prdMasterId = data?.prdMasterId {
            profileViewModel.updateWishlist(prdMasterId: "\(prdMasterId)", isFav: true) { (proceed, data) in
                if proceed {
                    self.wishlist.remove(at: index)
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
                }
            }
        }
    }
    
    func addToCart(index: Int) {
        let data = wishlist[index]
        if let prdMasterId = data?.prdMasterId {
            productViewModel.getProductDetails(productId: prdMasterId) { (proceed, data) in
                if proceed {
                    let vc = getVC(sb: "Landing", vc: "ProductDetailsVC") as! ProductDetailsVC
                    if let data = data {
                        vc.productDetailsData = data
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    
}

//MARK:- WishlistTVC
protocol WishlistTVCDelegate: class {
    func deleteWishlist(index: Int)
    func addToCart(index: Int)
}

class WishlistTVC: UITableViewCell {
    
    @IBOutlet weak var ivProduct: UIImageView!
    
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnAddToCart: UIButton!
    
    weak var delegate: WishlistTVCDelegate?
    
    override func awakeFromNib() {
        btnAddToCart.applyCornerRadius(cornerRadius: 4)
    }
    
    @IBAction func deleteHandler(_ sender: Any) {
        delegate?.deleteWishlist(index: self.tag)
    }
    
    @IBAction func addToCartHandler(_ sender: Any) {
        delegate?.addToCart(index: self.tag)
    }
    
}
