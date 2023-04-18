//
//  LoginPageVC.swift
//  Metastones
//
//  Created by Sonya Hew on 16/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class LoginPageVC: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var pageVCContainer: UIView!
    @IBOutlet var btnTabs: [UIButton]!
    
    let pageController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return controller
    }()
    
    var landingIndex: Int = 0
    var currentPageIndex = 0
    var pageContents: [UIViewController] = []
    
    let loginVC = getVC(sb: "Main", vc: "LoginVC") as! LoginVC
    let signupVC = getVC(sb: "Main", vc: "SignupVC") as! SignupVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBtns()
        setupPageVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            self.btnTabs[self.landingIndex].sendActions(for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupBtns() {
        for btn in btnTabs {
            btn.layer.borderColor = UIColor.msBrown.cgColor
            btn.layer.borderWidth = 1
            btn.applyCornerRadius(cornerRadius: 24)
            btn.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            
            btnLogin.setTitle(kLb.log_in.localized.capitalized, for: .normal)
            btnSignup.setTitle(kLb.sign_up.localized.capitalized, for: .normal)
        }
    }
    
    func setupPageVC() {
        var viewControllerStack = self.navigationController?.viewControllers ?? []
        if !viewControllerStack.isEmpty {
            viewControllerStack.removeLast()
        }
        loginVC.viewControllerStack = viewControllerStack
        signupVC.viewControllerStack = viewControllerStack
        
        pageContents = [loginVC, signupVC]
        pageController.delegate = self
        pageController.setViewControllers([pageContents.first!], direction: .forward, animated: true, completion: nil)
        addChild(pageController)
        pageVCContainer.addSubviewAndPinEdges(pageController.view)
        pageController.didMove(toParent: self)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        selectBtn(forBtns: [btnLogin, btnSignup], isSelected: false)
        selectBtn(forBtns: [sender], isSelected: true)
        if sender == btnLogin {
            switchTab(index: 0)
            landingIndex = 0
        } else {
            switchTab(index: 1)
            landingIndex = 1
        }
    }
    
    func selectBtn(forBtns btns: [UIButton], isSelected: Bool) {
        if isSelected {
            for btn in btns {
                btn.backgroundColor = .msBrown
                btn.setTitleColor(.white, for: .normal)
            }
        } else {
            for btn in btns {
                btn.backgroundColor = .clear
                btn.setTitleColor(.msBrown, for: .normal)
            }
        }
    }
    
    func switchTab(index : Int) {
        if currentPageIndex > index {
            pageController.setViewControllers([pageContents[index]], direction: .reverse, animated: true, completion: nil)
        } else {
            pageController.setViewControllers([pageContents[index]], direction: .forward, animated: true, completion: nil)
        }
        currentPageIndex = index
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension LoginPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pageContents.firstIndex(of: viewController) {
            if index - 1 >= 0 {
                return pageContents[index - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pageContents.firstIndex(of: viewController) {
            if index + 1 < pageContents.count {
                return pageContents[index + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let index = pageViewController.viewControllers?.first?.view.tag {
                currentPageIndex = index
            }
        }
    }
}
