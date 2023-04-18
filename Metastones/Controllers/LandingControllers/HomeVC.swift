//
//  HomeVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import FSPagerView

class HomeVC: UIViewController {
    
    let appData = AppData.shared
    let popupManager = PopupManager.shared
    let homeViewModel = HomeViewModel()
    weak var delegate: MenuDelegate?
    
    weak var tabDelegate: SwitchTabDelegate?

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var ivTopLogo: UIImageView!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnCart: UIButton!
    @IBOutlet weak var ivBottomLogo: UIImageView!
    
    //cart indicator
    @IBOutlet weak var vwIndicator: UIView!
    @IBOutlet weak var lbIndicator: UILabel!
    
    let cartViewModel = CartViewModel()
    let refresher = UIRefreshControl()
    
    var homeData: HomeDataModel? {
        didSet {
            appData.fbLiveData = homeData?.fbLive ?? []
        }
    }

    let ivBottomLogoWidth = UIScreen.main.bounds.width * 0.7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ivTopLogo.alpha = 0
        setupTableView()
        setupCartIndicator()
        setupData()
        //if not authorized, hide btnQR
        
        if appData.appSetting?.popup?.count ?? 0 > 0 {
            self.popupManager.showAlert(destVC: self.popupManager.getSignUpSuccessPopup()) { (_) in
                self.appData.data?.signUpSuccessImgStr = ""
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appData.isLoggedIn {
            cartViewModel.getCart { (proceed, data) in
                self.lbIndicator.text = "\(self.appData.data?.cartItemCount ?? 0)"
            }
        }
        self.btnLive.hideShowBtnLive()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let voucher = appData.profile?.welcomeVoucher, voucher == 1, self.appData.data?.isRedeemedVoucher == false {
            popupManager.showAlert(destVC: popupManager.getWelcomePopup(title: kLb.welcome_voucher_title.localized, metaCoins: kLb.welcome_voucher_message.localized, points: "", isClaim: false)) { (btnTitle) in
                self.appData.data?.isRedeemedVoucher = true
            }
        }
        
        if let rewards = appData.profile?.reward, rewards.count > 0 {
            for item in rewards {
                if let type = item?.type, let point = item?.point {
                    popupManager.showAlert(destVC: popupManager.getWelcomePopup(title: type, metaCoins: point, points: kLb.meta_points.localized))
                }
            }
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewArrivalsTVC.self, forCellReuseIdentifier: "newArrivalsTVC")
        tableView.register(UINib(nibName: "NewArrivalsTVHC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "newArrivalsTVHC")
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
    }
    
    @objc func refreshData() {
        setupData()
    }
    
    func setupCartIndicator() {
        vwIndicator.applyCornerRadius(cornerRadius: vwIndicator.bounds.height/2)
    }
    
    func setupData() {
        homeViewModel.getLanding { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.homeData = data?.data
                self.btnLive.hideShowBtnLive()
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func menuHandler(_ sender: Any) {
        delegate?.showHideMenu()
    }
    
    @IBAction func cartHandler(_ sender: Any) {
        navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
    }
    
    @IBAction func liveHandler(_ sender: Any) {
        enterFbLive()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        let heightToFade = CGFloat(46*2)
        ivTopLogo.alpha = offset/heightToFade
        ivBottomLogo.alpha = 1-(offset/heightToFade)
        
        let scale = (heightToFade-offset)/heightToFade
        ivBottomLogo.transform = CGAffineTransform(scaleX: min(1, scale) , y: min(1, scale))
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "newArrivalsTVHC") as! NewArrivalsTVHC
        header.tabDelegate = tabDelegate
        
        switch section {
            case 1:
                header.lbTitle.text = kLb.suggested_range.localized
                return header
            
            case 2:
                header.lbTitle.text = kLb.new_arrivals.localized
                return header
            
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case 1, 2:
                return 28
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let screenWidth = UIScreen.main.bounds.width
        let inset: CGFloat = 20
        let verticalMargin: CGFloat = 42
        
        switch indexPath.section {
        case 0:
            if let bannerCount = homeData?.banner?.header?.count, bannerCount > 0 {
                let width = UIScreen.main.bounds.width
                let height = width/2
                return height
            } else {
                return 0
            }
            
        case 1, 2:
            let cellGap: CGFloat = 16
            let peek: CGFloat = 50
            let width = screenWidth/1.5 - inset - cellGap - peek
            let height = width*200/276
            return height + verticalMargin
            
        case 3:
            return screenWidth*384/360
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "newArrivalsTVC") as! NewArrivalsTVC
        productCell.selectionStyle = .none
        productCell.delegate = tabDelegate
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pagerTVC") as! PagerTVC
            cell.selectionStyle = .none
            cell.data = homeData?.banner?.header
            cell.awakeFromNib()
            return cell
            
        case 1:
            productCell.data = homeData?.product?.suggestionProducts
            return productCell
            
        case 2:
            productCell.data = homeData?.product?.newArrivalProducts
            return productCell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customizeTVC") as! CustomizeTVC
            cell.selectionStyle = .none
            cell.vc = self
            cell.delegate = self
            return cell

        default:
            return UITableViewCell()
        }
    }
}


//MARK:- PagerTVC
class PagerTVC: UITableViewCell, FSPagerViewDelegate, FSPagerViewDataSource {
    
    var data: [BannerDataModel]? {
        didSet {
            pagerView.reloadData()
        }
    }
    let pageControl = UIPageControl()
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            pagerView.delegate = self
            pagerView.dataSource = self
            pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.width/2
            pagerView.itemSize = CGSize(width: width, height: height)
            pagerView.automaticSlidingInterval = 3.0
            pagerView.interitemSpacing = 0
            self.pagerView.isInfinite = true
            for subview in pagerView.subviews {
                subview.clipsToBounds = true
            }
        }
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return data?.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.clipsToBounds = true
        
        let vw = UIView()
        vw.tag = 99
        
        for subview in cell.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        
        cell.addSubview(vw)
        cell.sendSubviewToBack(vw)
        vw.backgroundColor = .white
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.heightAnchor.constraint(equalToConstant: 100).isActive = true
        vw.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        vw.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        vw.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -2).isActive = true
        vw.clipsToBounds = true
        
        //vw.applyCornerRadius(cornerRadius: 20)
        //vw.addShadow(withRadius: 5, opacity: 0.4, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 5))
        
        cell.imageView?.loadWithCache(strUrl: data?[index].imgPath)
        cell.imageView?.contentMode = .scaleAspectFill
        //cell.contentView.applyCornerRadius(cornerRadius: 20)
        cell.contentView.backgroundColor = .msBrown
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        deepLinkHandler(url: data?[index].url, navController: UIApplication.topViewController()?.navigationController)
        pagerView.deselectItem(at: index, animated: true)
    }
    
    override func awakeFromNib() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
    }
}

extension HomeVC: CustomizeTVCDelegate {
    func didSubmitBazi(data: CalculateBzDataModel?, userNameDOB: String?) {
        let colorBalanceVC = getVC(sb: "Landing", vc: "ColorBalanceVC") as! ColorBalanceVC
        colorBalanceVC.bzData = data
        colorBalanceVC.userNameDOB = userNameDOB
        self.navigationController?.pushViewController(colorBalanceVC, animated: true)
    }
}

//MARK:- CustomizeTVC
protocol CustomizeTVCDelegate: class {
    func didSubmitBazi(data: CalculateBzDataModel?, userNameDOB: String?)
}

class CustomizeTVC: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tfDOB: DatePickerTF!
    @IBOutlet weak var tfTOB: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var btnSubmit: BrownButton!
    
    @IBOutlet weak var lbSystem: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var vwSkipContainer: UIView!
    @IBOutlet weak var lbSkip: UILabel!
    @IBOutlet weak var lbCustomize: UILabel!
    @IBOutlet weak var topSVConstraint: NSLayoutConstraint!
    
    let appData = AppData.shared
    let popupManager = PopupManager.shared
    let homeViewModel = HomeViewModel()
    let titles = [kLb.date_of_birth.localized, kLb.time_of_birth.localized, kLb.gender.localized]
    let placeholders = [kLb.dd_mm_yyyy.localized, kLb.hour_optional.localized, kLb.select_gender.localized]
    
    var vc: UIViewController = UIViewController()
    var day: String? = ""
    var month: String? = ""
    var year: String? = ""
    var hour: String? = ""
    var gender: String? = ""
    var selectedHour: Int? = 0
    var selectedGender: Int? = 0
    
    weak var delegate: CustomizeTVCDelegate?
    
    override func awakeFromNib() {
        if isSmallScreen {
            btnSubmit.heightAnchor.constraint(equalToConstant: 42).isActive = true
            stackView.spacing = 8
            topSVConstraint.constant = 18
        }
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -100
        let minDate = calendar.date(byAdding: components, to: Date())!

        tfDOB.datePicker.minimumDate = minDate
        tfDOB.datePicker.maximumDate = Date()
        tfDOB.delegate = self
        tfTOB.delegate = self
        tfGender.delegate = self
        
        let tfs = [tfDOB, tfTOB, tfGender]
        for (index, tf) in tfs.enumerated() {
            tf?.setupTextField(placeholder: placeholders[index], titleLeft: titles[index])
            if isSmallScreen {
                tf?.applyCornerRadius(cornerRadius: 21)
            }
        }
        let rotation270Deg = 270 * (CGFloat.pi/180)
        let rotate270Transform = CGAffineTransform(rotationAngle: rotation270Deg)
        vwSkipContainer.transform = rotate270Transform
        lbCustomize.transform = rotate270Transform
        
        lbSystem.text = kLb.metastones_tailored_design_system.localized
        lbTitle.text = "\(kLb.personalize_your_crystal_with_your_life_balance_color.localized)"
        btnSubmit.setTitle(kLb.submit.localized.capitalized, for: .normal)
    }
    
    @IBAction func submitHandler(_ sender: Any) {
        if let day = day, day != "" {
            if tfDOB.text != "" {
                homeViewModel.calculateBazi(year: year, month: month, day: day, hour: hour, gender: gender) { (proceed, data) in
                    if proceed {
                        var hourStr: String?
                        if let hour = self.hour, hour != "" {
                            hourStr = "\(hour):00:00"
                        }
                        var dobStr = "\(day)/\(self.month ?? "")/\(self.year ?? "") \(hourStr ?? "")\n"
                        if self.appData.isLoggedIn {
                            self.popupManager.showAlert(destVC: self.popupManager.getSaveDOBPopup(title: kLb.do_you_want_to_save_this_date_of_birth.localized, leftBtnTitle: kLb.save.localized, rightBtnTitle: kLb.no_thanks.localized, year: self.year, month: self.month, day: self.day, hour: self.hour, gender: self.gender)) { (btnTitle, userData) in
                                
                                if btnTitle == kLb.save.localized {
                                    self.popupManager.showAlert(destVC: self.popupManager.getSuccessPopup(title: kLb.successfully_saved_into_bazi_book_list.localized, desc: "")) { (btnTitle) in
                                        if let userData = userData {
                                            dobStr = "\(userData)\n\(dobStr)"
                                        }
                                        self.delegate?.didSubmitBazi(data: data?.data, userNameDOB: dobStr)
                                    }
                                } else {
                                    self.delegate?.didSubmitBazi(data: data?.data, userNameDOB: dobStr)
                                }
                            }
                        } else {
                            self.delegate?.didSubmitBazi(data: data?.data, userNameDOB: dobStr)
                        }
                    }
                }
            } else {
                popupManager.showAlert(destVC: popupManager.getAlertPopup(title: kLb.date_of_birth_is_required.localized, desc: ""))
            }
        } else {
            popupManager.showAlert(destVC: popupManager.getAlertPopup(title: kLb.date_of_birth_is_required.localized, desc: ""))
        }
    }
}

extension CustomizeTVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfTOB {
            getPickerSheetedController(title: kLb.time_of_birth.localized, dataArr: hours, forVC: vc, selectedRow: selectedHour) { (btnTitle, btnIndex) in
                self.hour = btnTitle
                self.selectedHour = btnIndex
                textField.text = btnTitle
            }
            return false
            
        } else if textField == tfGender {
            getPickerSheetedController(title: kLb.gender.localized, dataArr: genders.map({ $0.title }), forVC: vc, selectedRow: selectedGender) { (btnTitle, btnIndex) in
                self.gender = genders.filter({ $0.title == btnTitle }).map({ $0.value }).first
                self.selectedGender = btnIndex
                textField.text = btnTitle
            }
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfDOB {
            day = tfDOB.datePicker.date.day
            month = tfDOB.datePicker.date.month
            year = tfDOB.datePicker.date.year
        }
    }
}


//MARK:- BraceletTVC
class BraceletTVC: UITableViewCell {
    
    @IBOutlet weak var vwBanner: UIView!
    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        ivBanner.image = #imageLiteral(resourceName: "home-footer")
        vwBanner.applyCornerRadius(cornerRadius: 20)
        
        lbTitle.text = kLb.bracelet.localized.uppercased()
    }
}
