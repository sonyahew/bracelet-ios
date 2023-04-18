//
//  CrystalsVC.swift
//  Metastones
//
//  Created by Sonya Hew on 05/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class CrystalsVC: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var titles: [ProductCategoryModel]?
    var selectedCategory: ProductCategoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = kLb.crystals_collection.localized.capitalized
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension CrystalsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "crystalCVC", for: indexPath) as! CrystalCVC
        cell.lbTitle.text = titles?[indexPath.row].name ?? ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideMargin: CGFloat = 32*2
        let cellGap: CGFloat = 14
        let width = (UIScreen.main.bounds.width - sideMargin - cellGap)/2
        let height: CGFloat = 45
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 26, left: 32, bottom: 26, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = titles?[indexPath.item]
        self.sheetViewController?.dismiss(animated: true)
    }
}
class CrystalCVC: UICollectionViewCell {
    
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        vwContainer.layer.borderColor = UIColor(hex: 0xBCBCBC).cgColor
        vwContainer.layer.borderWidth = 1
    }
}
