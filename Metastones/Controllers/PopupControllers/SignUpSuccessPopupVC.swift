//
//  SignUpSuccessPopupVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 18/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

protocol SignUpSuccessPopupVCDelegate: class {
    func tapClose(sourceVC : SignUpSuccessPopupVC)
}

class SignUpSuccessPopupVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var svMain: UIScrollView!
    @IBOutlet weak var lbStep: UILabel!
    
    var totalPage = 0
    
    weak var delegate: SignUpSuccessPopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        svMain.delegate = self
        let data = AppData.shared.appSetting?.popup ?? []
        for (index, item) in data.enumerated() {
            let ivContent = UIImageView()
            ivContent.backgroundColor = .clear
            ivContent.loadWithCache(strUrl: item.imgPath)
            ivContent.contentMode = .scaleAspectFill
            let xPosition = (self.view.frame.size.width * 0.8) * CGFloat(index)
            ivContent.frame = CGRect(x: xPosition, y: 0, width: self.view.frame.size.width * 0.8, height: self.view.frame.size.width * 0.8)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            ivContent.isUserInteractionEnabled = true
            ivContent.addGestureRecognizer(tapGestureRecognizer)
            
            svMain.contentSize.width = (self.view.frame.size.width * 0.8) * CGFloat(index + 1)
            svMain.addSubview(ivContent)
            
            totalPage += 1
        }
        
        lbStep.font = .boldSystemFont(ofSize: 16)
        lbStep.textColor = .white
        lbStep.text = "\(svMain.currentPage)/\(totalPage)"
        
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        self.view.addGestureRecognizer(tapOutside)
    }
    
    @objc
    func dismissVC() {
        delegate?.tapClose(sourceVC: self)
    }
    
    @objc
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        deepLinkHandler(url: AppData.shared.appSetting?.popup?[svMain.currentPage-1].url, navController: UIApplication.topViewController()?.navigationController)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        lbStep.text = "\(scrollView.currentPage)/\(totalPage)"
    }
}
