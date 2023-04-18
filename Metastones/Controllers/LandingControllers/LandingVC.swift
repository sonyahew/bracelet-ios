//
//  LandingVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

var genders : [(title: String, value: String)] = []
var hours : [String] = []

class LandingVC: UIViewController {
    
    weak var delegate: MenuDelegate?
    let appData = AppData.shared
    
    var didLaunch = false
    var categoryFromMenu: Int?
    var metastonesVC = MetastonesVC()
    
    //footer
    @IBOutlet weak var vwFooter: UIView!
    @IBOutlet weak var footerBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var btnlogin: UIButton!
    
    //tabbar
    let tabController = UITabBarController()
//    let tabBarIcons = [#imageLiteral(resourceName: "icon-home-b"), #imageLiteral(resourceName: "icon-meta-b"), #imageLiteral(resourceName: "icon-create-b"), #imageLiteral(resourceName: "icon-myorder-b"), #imageLiteral(resourceName: "icon-acc-b")]
//    let tabNames = ["Home", "Metastones", "Create", "My Order", "Account"]
//    let tabVCNames = ["HomeVC", "MetastonesVC", "CreateVC", "MyOrderVC", "AccountVC"]
    
    let tabBarIcons = [#imageLiteral(resourceName: "icon-home-b"), #imageLiteral(resourceName: "icon-meta-b"), #imageLiteral(resourceName: "icon-create-b"), #imageLiteral(resourceName: "icon-meta-says-on"), #imageLiteral(resourceName: "icon-acc-b")]
    let tabNames = [kLb.home.localized, kLb.products.localized, kLb.personalized.localized, kLb.meta_says.localized, kLb.account.localized]
    let tabVCNames = ["HomeVC", "MetastonesVC", "CreateVC", "AnnouncementVC", "AccountVC"]
    let loginVC = getVC(sb: "Main", vc: "LoginPageVC") as! LoginPageVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genders = [(kLb.male.localized, "M"), (kLb.female.localized, "F")]
        hours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23].map({ "\($0)" })
        setupTabBar()
        setupFooter()
        view.bringSubviewToFront(vwFooter)
        
        btnSignup.setTitle(kLb.sign_up.localized.capitalized, for: .normal)
        btnlogin.setTitle(kLb.log_in.localized.capitalized, for: .normal)
        view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFooter()
        if menuOpened {
            if #available(iOS 11.0, *) {
                additionalSafeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? UIEdgeInsets()
            }
        } else {
            if #available(iOS 11.0, *) {
                additionalSafeAreaInsets = UIEdgeInsets()
            }
        }
    }
    
    func menuClosed() {
        if let category = categoryFromMenu {
            metastonesVC.categoryFromMenu = category
            metastonesVC.menuClosed()
            categoryFromMenu = nil
        }
    }
    
    func setupFooter() {
        //pending authorized logic here -
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            if hasTopNotch {
                bottomPadding = window?.safeAreaInsets.bottom ?? 0
            }
        }
        let height = tabBarController?.tabBar.frame.height ?? 49.0
        footerBtmConstraint.constant = bottomPadding + height
        //separatorBtmConstraint.constant = bottomPadding + height
        
        vwFooter.isHidden = appData.isLoggedIn
    }
    
    func setupTabBar() {
        tabController.delegate = self
        tabController.tabBar.tintColor = .msBrown
        tabController.tabBar.barTintColor = .white
        tabController.tabBar.unselectedItemTintColor = UIColor(hex: 0x1D2236)
        var controllers: [UIViewController] = []
        for (index, icon) in tabBarIcons.enumerated() {
            let tabItem = UITabBarItem(title: tabNames[index], image: icon.withRenderingMode(.alwaysTemplate), selectedImage: icon.withRenderingMode(.alwaysTemplate))
            tabItem.tag = index
            tabItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2.5)

            let pageVC = getVC(sb: "Landing", vc: tabVCNames[index])
            pageVC.tabBarItem = tabItem
            
            switch index {
            case 0:
                (pageVC as! HomeVC).delegate = delegate
                (pageVC as! HomeVC).tabDelegate = self
            case 1:
                (pageVC as! MetastonesVC).delegate = delegate
                metastonesVC = pageVC as! MetastonesVC
            case 2:
                (pageVC as! CreateVC).delegate = delegate
            case 3:
                (pageVC as! AnnouncementVC).isMenu = true
                (pageVC as! AnnouncementVC).delegate = delegate
                (pageVC as! AnnouncementVC).tabDelegate = self
            case 4:
                (pageVC as! AccountVC).delegate = delegate
                (pageVC as! AccountVC).tabDelegate = self
            default:
                print("delegate assigning error")
            }
            
            controllers.append(pageVC)
        }
        tabController.viewControllers = controllers
        addChild(tabController)
        view.addSubviewAndPinEdges(tabController.view)
    }
    
    @IBAction func signupHandler(_ sender: Any) {
        loginVC.landingIndex = 1
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func loginHandler(_ sender: Any) {
        loginVC.landingIndex = 0
        navigationController?.pushViewController(loginVC, animated: true)
    }
}

extension LandingVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController.isKind(of: AccountVC.self){
            return isMemberUser(vc: self.navigationController)
        } else if viewController.isKind(of: AnnouncementVC.self) {
            let vc = getVC(sb: "Landing", vc: "AnnouncementVC") as! AnnouncementVC
            vc.modalPresentationStyle = .fullScreen
            vc.isMenu = false
            self.present(vc, animated: true)
            return false
        }
        
        return true
    }
}

extension LandingVC: SwitchTabDelegate {
    func switchTab(to: Int) {
        tabController.selectedIndex = to
    }
}
