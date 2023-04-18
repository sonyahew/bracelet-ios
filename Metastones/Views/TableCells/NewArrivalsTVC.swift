//
//  NewArrivalsTVC.swift
//  Metastones
//
//  Created by Sonya Hew on 22/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

@objc protocol SwitchTabDelegate {
    func switchTab(to: Int)
}

class NewArrivalsTVC: UITableViewCell {
    
    let productViewModel = ProductViewModel()
    
    weak var delegate: SwitchTabDelegate?
    
    var data: [ProductDataModel]? = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        clipsToBounds = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubviewAndPinEdges(collectionView)
        
        //collectionView.register(UINib(nibName: "NewArrivalsCVFC", bundle: Bundle.main), forCellWithReuseIdentifier: "newArrivalsCVFC")
        collectionView.register(UINib(nibName: "NewArrivalsCVC", bundle: Bundle.main), forCellWithReuseIdentifier: "newArrivalsCVC")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension NewArrivalsTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 1 {
//        } else {
//            return 1
//        }
        return data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.section == 1 {
//
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newArrivalsCVFC", for: indexPath) as! NewArrivalsCVFC
//            if indexPath.section == 0 {
//                cell.setupAs(position: .first)
//            } else {
//                cell.setupAs(position: .last)
//            }
//            return cell
//        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newArrivalsCVC", for: indexPath) as! NewArrivalsCVC
        cell.data = data?[indexPath.item]
        cell.ivProduct.loadWithCache(strUrl: cell.data?.imgPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.section == 0 || indexPath.section == 2 {
//            delegate?.switchTab(to: 1)
//        } else {
//            
//        }
        
        if let products = data?[indexPath.item] {
            productViewModel.getProductDetails(productId: products.id ?? 0) { (proceed, data) in
                if proceed {
                    let vc = getVC(sb: "Landing", vc: "ProductDetailsVC") as! ProductDetailsVC
                    if let data = data {
                        vc.productDetailsData = data
                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width/1.5
        let inset: CGFloat = 20
        let cellGap: CGFloat = 16
        let peek: CGFloat = 50
        
        let width = screenWidth - inset - cellGap - peek
        let height = width*200/276
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
