//
//  ColorBalanceVC.swift
//  Metastones
//
//  Created by Sonya Hew on 15/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ColorBalanceVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var vwIndicator: UIView!
    @IBOutlet weak var lbIndicator: UILabel!
    
    let appData = AppData.shared
    let productViewModel = ProductViewModel()
    let profileViewModel = ProfileViewModel()
    let popup = PopupManager.shared
    
    var bzData: CalculateBzDataModel?
    
    var userNameDOB: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwIndicator.applyCornerRadius(cornerRadius: vwIndicator.bounds.height/2)
        setupCollectionView()
        
        lbTitle.text = kLb.your_life_balanced_color.localized.capitalized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lbIndicator.text = "\(self.appData.data?.cartItemCount ?? 0)"
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "ListingCVC", bundle: nil), forCellWithReuseIdentifier: "listingCVC")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    }
    
    @IBAction func cartHandler(_ sender: Any) {
        navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
    }
       
    @IBAction func qrHandler(_ sender: Any) {
           navigationController?.pushViewController(getVC(sb: "Landing", vc: "NotificationVC"), animated: true)
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ColorBalanceVC: ColorBalCVHCDelegate, CustomizeTVCDelegate {
    func didSubmitBazi(data: CalculateBzDataModel?, userNameDOB: String?) {
        bzData = data
        collectionView.reloadData()
    }
    
    func changeDOB() {
        popup.showAlert(destVC: popup.getColorBalPopup(delegate: self))
    }
    
    func personalizedOwn() {
        let personalizedVC = getVC(sb: "Create", vc: "PersonalizedVC") as! PersonalizedVC
        personalizedVC.baziBalance = bzData?.colorBalance?.toJSONString()
        personalizedVC.userNameDOB = userNameDOB
        self.navigationController?.pushViewController(personalizedVC, animated: true)
    }
    
    func exploreSecretCode() {
        let aboutMetaVC = getVC(sb: "Landing", vc: "AboutMetaVC") as! AboutMetaVC
        aboutMetaVC.goToTitle = "meta_secret_color_code"
        navigationController?.pushViewController(aboutMetaVC, animated: true)
    }
}

extension ColorBalanceVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bzData?.suggestedProduct.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listingCVC", for: indexPath) as! ListingCVC
        cell.tag = indexPath.item
        cell.delegate = self
        if let products = bzData?.suggestedProduct[indexPath.item] {
            cell.ivProduct.loadWithCache(strUrl: products.imgPath)
            cell.lbPrice.text = (products.currencyCode ?? "") + (products.currentUnitPrice ?? "")
            cell.lbDesc.text = products.productName
            cell.vwBestSeller.isHidden = products.bestSeller ?? 0 == 0
            cell.isFav = products.isWishlist
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "colorBalCVHC", for: indexPath) as! ColorBalCVHC
            header.bzData = bzData
            header.awakeFromNib()
            header.delegate = self
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = width*380/350
        return CGSize(width: UIScreen.main.bounds.width, height: 820)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideMargin: CGFloat = 32*2
        let cellGap: CGFloat = 14
        let width = (UIScreen.main.bounds.width - sideMargin - cellGap)/2
        let height = width + 68
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 32, bottom: 38, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let products = bzData?.suggestedProduct[indexPath.item] {
            productViewModel.getProductDetails(productId: products.id ?? 0) { (proceed, data) in
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

extension ColorBalanceVC: ListingCVCDelegate {
    func updateWishlist(index: Int) {
        let data = bzData?.suggestedProduct[index]
        if let prdMasterId = data?.id, let isFav = data?.isWishlist {
            profileViewModel.updateWishlist(prdMasterId: "\(prdMasterId)", isFav: isFav) { (proceed, data) in
                if proceed {
                    self.bzData?.suggestedProduct[index]?.wishlist = isFav ? 0 : 1
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

protocol ColorBalCVHCDelegate: class {
    func changeDOB()
    func personalizedOwn()
    func exploreSecretCode()
}

//MARK:- ColorBalCVHC
class ColorBalCVHC: UICollectionReusableView {
    
    let popup = PopupManager.shared
    
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbDay: UILabel!
    @IBOutlet weak var lbMonth: UILabel!
    @IBOutlet weak var lbYear: UILabel!
    
    @IBOutlet var timeBazis: [UIImageView]!
    @IBOutlet var dayBazis: [UIImageView]!
    @IBOutlet var monthBazis: [UIImageView]!
    @IBOutlet var yearBazis: [UIImageView]!

    @IBOutlet weak var lbGold: UILabel!
    @IBOutlet weak var lbWood: UILabel!
    @IBOutlet weak var lbWater: UILabel!
    @IBOutlet weak var lbFire: UILabel!
    @IBOutlet weak var lbEarth: UILabel!
    
    @IBOutlet var vwElements: [UIView]!
    
    @IBOutlet weak var lbGoldValue: UILabel!
    @IBOutlet weak var lbWoodValue: UILabel!
    @IBOutlet weak var lbWaterValue: UILabel!
    @IBOutlet weak var lbFireValue: UILabel!
    @IBOutlet weak var lbEarthValue: UILabel!
    
    @IBOutlet weak var lbGoldDesc: UILabel!
    @IBOutlet weak var lbWoodDesc: UILabel!
    @IBOutlet weak var lbWaterDesc: UILabel!
    @IBOutlet weak var lbFireDesc: UILabel!
    @IBOutlet weak var lbEarthDesc: UILabel!
    
    @IBOutlet weak var lbCustomize: UILabel!
    @IBOutlet weak var btnCreateOwn: BrownButton!
    @IBOutlet weak var btnExplore: ReversedWhiteBackBrownButton!
    @IBOutlet weak var lbLifeChart: UILabel!
    @IBOutlet weak var lbSuggested: UILabel!
    @IBOutlet weak var lbNote: UILabel!
    
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var btnCreate: BrownButton!
    @IBOutlet weak var btnChangeDOB: BrownButton!
    
    @IBOutlet weak var svBazi1: UIStackView!
    @IBOutlet weak var svBazi2: UIStackView!
    
    @IBOutlet weak var vwContainer: UIView!
    
    var bzData: CalculateBzDataModel?
    
    weak var delegate: ColorBalCVHCDelegate?
    
    override func awakeFromNib() {
        let imgArr = [timeBazis, dayBazis, monthBazis, yearBazis]
        for arr in imgArr {
            for img in arr! {
                img.contentMode = .scaleAspectFit
                img.layer.borderColor = UIColor.black.cgColor
                img.layer.borderWidth = 1.5
            }
        }
        
        lbGoldValue.text = "\(bzData?.colorBalance?.metal ?? 0.00)%"
        lbWoodValue.text = "\(bzData?.colorBalance?.wood ?? 0.00)%"
        lbWaterValue.text = "\(bzData?.colorBalance?.water ?? 0.00)%"
        lbFireValue.text = "\(bzData?.colorBalance?.fire ?? 0.00)%"
        lbEarthValue.text = "\(bzData?.colorBalance?.earth ?? 0.00)%"
        
        lbTime.text = kLb.time.localized.capitalized
        lbDay.text = kLb.day.localized.capitalized
        lbMonth.text = kLb.month.localized.capitalized
        lbYear.text = kLb.year.localized.capitalized
        
        lbGold.text = kLb.gold.localized.capitalized
        lbWood.text = kLb.wood.localized.capitalized
        lbWater.text = kLb.water.localized.capitalized
        lbFire.text = kLb.fire.localized.capitalized
        lbEarth.text = kLb.earth.localized.capitalized
        
        lbGoldDesc.text = kLb.gold_desc.localized
        lbWoodDesc.text = kLb.wood_desc.localized
        lbWaterDesc.text = kLb.water_desc.localized
        lbFireDesc.text = kLb.fire_desc.localized
        lbEarthDesc.text = kLb.earth_desc.localized
        
        lbCustomize.text = kLb.customize_own_bracelet.localized
        lbLifeChart.text = kLb.your_life_chart.localized
        lbNote.text = "*\(kLb.color_balance_disclaimer.localized)"
        
        yearBazis[0].loadWithCache(strUrl: bzData?.bazi?.year?.indices.contains(0) ?? false ? bzData?.bazi?.year?[0].urlPercentEncoding : "")
        yearBazis[1].loadWithCache(strUrl: bzData?.bazi?.year?.indices.contains(1) ?? false ? bzData?.bazi?.year?[1].urlPercentEncoding : "")
        
        monthBazis[0].loadWithCache(strUrl: bzData?.bazi?.month?.indices.contains(0) ?? false ? bzData?.bazi?.month?[0].urlPercentEncoding : "")
        monthBazis[1].loadWithCache(strUrl: bzData?.bazi?.month?.indices.contains(1) ?? false ? bzData?.bazi?.month?[1].urlPercentEncoding : "")
        
        dayBazis[0].loadWithCache(strUrl: bzData?.bazi?.day?.indices.contains(0) ?? false ? bzData?.bazi?.day?[0].urlPercentEncoding : "")
               dayBazis[1].loadWithCache(strUrl: bzData?.bazi?.day?.indices.contains(1) ?? false ? bzData?.bazi?.day?[1].urlPercentEncoding : "")
        
        timeBazis[0].loadWithCache(strUrl: bzData?.bazi?.time?.indices.contains(0) ?? false ? bzData?.bazi?.time?[0].urlPercentEncoding : "", placeholder: UIImage())
        timeBazis[1].loadWithCache(strUrl: bzData?.bazi?.time?.indices.contains(1) ?? false ? bzData?.bazi?.time?[1].urlPercentEncoding : "", placeholder: UIImage())

        
        for vw in vwElements {
            vw.applyCornerRadius(cornerRadius: 10)
        }
        
        if (bzData?.suggestedProduct.count ?? 0) > 0 {
            lbSuggested.text = kLb.suggested_range.localized.capitalized
            vwContainer.addShadow(withRadius: 6, opacity: 0.2, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 3))
        } else {
            lbSuggested.text = ""
        }
        
        if isSmallScreen {
            svBazi1.spacing = 8
            svBazi2.spacing = 8
        }
        
        btnCreateOwn.setTitle(kLb.personalized_your_bracelet_now.localized.capitalized, for: .normal)
        btnCreateOwn.titleLabel?.textAlignment = .center
        btnExplore.setTitle(kLb.explore_your_secret_color_code.localized, for: .normal)
        btnExplore.titleLabel?.textAlignment = .center
        btnCreate.setTitle(kLb.create_own.localized.capitalized, for: .normal)
        btnChangeDOB.setTitle(kLb.change_dob.localized.capitalized, for: .normal)
        
        svButtons.subviews.first?.isHidden = true
    }
    
    @IBAction func createOwnHandler(_ sender: Any) {
        delegate?.personalizedOwn()
    }
    
    @IBAction func exploreHandler(_ sender: Any) {
        delegate?.exploreSecretCode()
    }
    
    @IBAction func createHandler(_ sender: Any) {
    }
    
    @IBAction func changeDOBHandler(_ sender: Any) {
        delegate?.changeDOB()
    }
}
