//
//  MenuVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

var menuOpened = false
var menuPush: Int?

@objc protocol MenuDelegate {
    func showHideMenu()
}

class MenuVC: UIViewController {
    
    let appData = AppData.shared
    let popup = PopupManager()
    
    var productCategories: [String]?
    var productCode: [String]?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnLanguage: UIButton!
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnFAQ: UIButton!
    
    let tapView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    private let translateX = UIScreen.main.bounds.width*0.9
    private let rowTitles = [[""],
                             [kLb.online_course.localized],
                             [kLb.share_earn.localized],
                             [""]]
    
    private var delta: CGFloat = 0
    private var isShrunk = false
    
    var panGesture = UIPanGestureRecognizer()
    var edgeGesture = UIScreenEdgePanGestureRecognizer()
    var tapGesture = UITapGestureRecognizer()
    
    var isExpanded = false
    
    var selectedCode: String = ""
    var toTab: Int? = nil
    
    var landingVC = LandingVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupTableView()
        getProductCategories()
        
        menuView.layer.transform = CATransform3DScale(menuView.layer.transform, 0.85, 0.85, 1)
        menuView.alpha = 0
        
//        let safeAreaBg = UIView()
//        safeAreaBg.backgroundColor = .blue
//        containerView.addSubview(safeAreaBg)
//        containerView.sendSubviewToBack(safeAreaBg)
//        safeAreaBg.translatesAutoresizingMaskIntoConstraints = false
//        safeAreaBg.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
//        safeAreaBg.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
//        safeAreaBg.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
//        safeAreaBg.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        btnLanguage.setTitle(kLb.language.localized, for: .normal)
        btnAbout.setTitle(kLb.about_meta.localized, for: .normal)
        btnFAQ.setTitle(kLb.faq.localized, for: .normal)

        containerView.addSubviewAndPinEdges(tapView)
        containerView.bringSubviewToFront(tapView)
        tapView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.layoutIfNeeded()
        //self.navigateToPrdList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tab = toTab {
            navigateToTab(tab: tab)
            toTab = nil
        }
    }
    
    func getProductCategories() {
        let prdViewModel = ProductViewModel()
        prdViewModel.getProductCategory { (proceed, data) in
            if proceed {
                self.productCategories = data?.data.map({($0?.name?.localized ?? "")})
                self.productCode = data?.data.map({($0?.code ?? "")})
                self.navigateToPrdList()
                self.tableView.reloadData()
            }
        }
    }
    
    func navigateToPrdList() {
        if selectedCode != "" {
            var categoryIndex = 0
            
            if productCode?.count ?? 0 > 0, productCode?.contains(selectedCode) ?? false, let index = self.productCode?.firstIndex(of: selectedCode) {
                categoryIndex = index+1
            }
            
            self.selectedCode = ""
            self.landingVC.switchTab(to: 1)
            self.landingVC.categoryFromMenu = categoryIndex
            self.landingVC.menuClosed()
        }
    }
    
    func navigateToTab(tab: Int) {
        self.landingVC.switchTab(to: tab)
    }
    
    func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(isDragged(gesture:)))
        view.addGestureRecognizer(panGesture)
        
        edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeDrag))
        edgeGesture.edges = .left
        view.addGestureRecognizer(edgeGesture)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped(gesture:)))
        tapGesture.isEnabled = true
        tapView.addGestureRecognizer(tapGesture)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "MenuTVHC", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "menuTVHC")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "containerLink") {
            landingVC = segue.destination as! LandingVC
            landingVC.delegate = self
        }
    }
    
    @objc func isDragged(gesture: UIPanGestureRecognizer) {
        if isShrunk {
            gestureDetected(gesture: gesture)
        }
    }
    
    @objc func containerTapped(gesture: UITapGestureRecognizer) {
        if isShrunk {
            closeMenu()
        }
    }
    
    @objc func edgeDrag(gesture: UIScreenEdgePanGestureRecognizer) {
        gestureDetected(gesture: gesture)
    }
    
    func openMenu() {
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, 0.75, 0.75, 1)
        transform = CATransform3DTranslate(transform, translateX, 0, 0)
        
        var menuTransform = CATransform3DIdentity
        menuTransform = CATransform3DScale(menuTransform, 1, 1, 1)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.containerView.layer.transform = transform
            //self.containerView.layer.cornerRadius = 20
            self.menuView.layer.transform = menuTransform
            self.menuView.alpha = 1
        }, completion: nil)
        isShrunk = true
        tapView.isHidden = false
        menuOpened = true
    }
    
    func closeMenu() {
        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, 1, 1, 1)
        transform = CATransform3DTranslate(transform, 0, 0, 0)
        
        var menuTransform = CATransform3DIdentity
        menuTransform = CATransform3DScale(menuTransform, 0.85, 0.85, 1)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.containerView.layer.transform = transform
            //self.containerView.layer.cornerRadius = 0
            self.menuView.layer.transform = menuTransform
            self.menuView.alpha = 0
        }, completion: nil)
        isShrunk = false
        tapView.isHidden = true
        menuOpened = false
    }
    
    func gestureDetected(gesture: UIPanGestureRecognizer) {
        var transform = CATransform3DIdentity
        var menuTransform = CATransform3DIdentity
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            transform = containerView.layer.transform

        case .changed:
            //containerView.layer.cornerRadius = 20
            delta = translation.x / view.frame.size.width

            var scale: CGFloat = 0
            if isShrunk {
                scale = 1 - ((1 - CGFloat(0.5)) * delta)
            } else {
                scale = 1 - ((1 - CGFloat(0.7)) * delta)
            }

            let minScale = min(1, scale)
            let maxScale = min(1.335, scale)
            let menuScale = 1 + ((1 - CGFloat(0.85)) * delta)

            if isShrunk {
                transform = CATransform3DScale(transform, maxScale, maxScale, 1)
                transform = CATransform3DTranslate(transform, max(translation.x/1.7, -475/1.7), 0, 0)
                menuTransform = CATransform3DScale(menuTransform, menuScale, menuScale, 1)
                print(translation.x)
            
                var concatTransform = CATransform3DIdentity
                concatTransform = CATransform3DScale(concatTransform, 0.75, 0.75, 1)
                concatTransform = CATransform3DTranslate(concatTransform, translateX, 0, 0)
                
                containerView.layer.transform = CATransform3DConcat(concatTransform, transform)
                
                menuView.alpha = 1 + delta
                menuView.layer.transform = menuTransform
                
            } else {
                if !isShrunk {
                    transform = CATransform3DTranslate(transform, max(translation.x/1.7, 0), 0, 0)
                    transform = CATransform3DScale(transform, minScale, minScale, 1)
                    menuTransform = CATransform3DScale(menuTransform, menuScale, menuScale, 1)
                    print(maxScale)
                    
                    var menuConcatTransform = CATransform3DIdentity
                    menuConcatTransform = CATransform3DScale(menuConcatTransform, 0.85, 0.85, 1)
                    
                    containerView.layer.transform = transform

                    menuView.alpha = delta
                    menuView.layer.transform = CATransform3DConcat(menuConcatTransform, menuTransform)
                }
            }
            
        case .ended:
            //pan distance to trigger auto close / open
            let bounceThreshold: CGFloat = isShrunk ? -150 : 150
            if translation.x < bounceThreshold { //return to normal
                closeMenu()
            } else { //to shrink
                openMenu()
            }
            
        default:
            closeMenu()
        }
    }
    
    @IBAction func languageHandler(_ sender: Any) {
        let langVC = getVC(sb: "Main", vc: "LanguageVC") as! LanguageVC
        langVC.delegate = self
        langVC.modalPresentationStyle = .overFullScreen
        present(langVC, animated: true)
    }
    
    @IBAction func aboutMetaHandler(_ sender: Any) {
        navigationController?.pushViewController(getVC(sb: "Landing", vc: "AboutMetaVC"), animated: true)
    }
    
    @IBAction func faqHandler(_ sender: Any) {
        navigateWeb(url: appData.appSetting?.faq?.url, html: appData.appSetting?.faq?.htmlContent, title: kLb.faq.localized)
    }
    
    func navigateWeb(url: String?, html: String?, title: String?) {
        let webVC = getVC(sb: "Landing", vc: "WebVC") as! WebVC
        webVC.strUrl = url
        webVC.strHtml = html
        webVC.vcTitle = title
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension MenuVC: LanguageVCDelegate {
    func langUpdated() {
        closeMenu()
        navigationController?.setViewControllers([getVC(sb: "Landing", vc: "MenuVC")], animated: true)
    }
}

extension MenuVC: MenuDelegate {
    func showHideMenu() {
        if isShrunk {
            closeMenu()
        } else {
            openMenu()
        }
    }
}

extension MenuVC: FilterDelegate {
    func didTapHeader(section: Int) {
        isExpanded = !isExpanded
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "menuTVHC") as! MenuTVHC
            header.lbTitle.text = kLb.products_collection.localized
            header.delegate = self
            return header
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "header")?.contentView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 56
        } else if section == 1 {
            return 0.01
        } else if section == 2 {
            return 0.01
        } else {
            return 44
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rowTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return productCategories?.count ?? 0
        } else {
            return rowTitles[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuTVC") as! MenuTVC
        cell.ivMetastones.image = #imageLiteral(resourceName: "metasay-text")
        if indexPath.section == 0 {
            cell.lbTitle.font = .systemFont(ofSize: 17, weight: .light)
            cell.title = productCategories?[indexPath.row] ?? ""
        } else {
            cell.title = rowTitles[indexPath.section][indexPath.row]
        }
        cell.isLogoHidden(bool: indexPath.section != 3 ? true : false)

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "header")?.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return isExpanded ? 44 : 0.01
        } else if section == 1 {
            return 0.01
        } else if section == 2 {
            return 0.01
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return isExpanded ? UITableView.automaticDimension : 0.01
        } else if indexPath.section == 2 {
            return 0.01
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0 :
            //NotificationCenter.default.post(name: Notification.Name("openMetastones"), object: nil)
            landingVC.switchTab(to: 1)
            landingVC.categoryFromMenu = indexPath.row+1
            landingVC.menuClosed()
            closeMenu()
        case 1:
            let metaVC = getVC(sb: "Landing", vc: "ProductListingVC") as! ProductListingVC
            navigationController?.pushViewController(metaVC, animated: true)
            
        case 2:
            navigateWeb(url: appData.appSetting?.shareEarn?.url, html: appData.appSetting?.shareEarn?.htmlContent, title: kLb.share_earn.localized)
            
        case 3:
            let metasaysVC = getVC(sb: "Landing", vc: "AnnouncementVC")
            metasaysVC.modalPresentationStyle = .fullScreen
            present(metasaysVC, animated: true)
            
        default:
            print("error")
        }
    }
}


//MARK:- MenuTVC
class MenuTVC: UITableViewCell {
    
    @IBOutlet weak var ivMetastones: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var title: String = "" {
        didSet {
            lbTitle.text = title
        }
    }
    
    func isLogoHidden(bool: Bool) {
        ivMetastones.isHidden = bool
    }
}
