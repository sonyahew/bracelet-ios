//
//  AboutMetaVC.swift
//  Metastones
//
//  Created by Sonya Hew on 20/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import WebKit

class AboutMetaVC: UIViewController {
    
    let appData = AppData.shared

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var webViewContentSize: CGSize? = CGSize.init()
    var webTVC = ProductDescTVC()
    var selectedIndex = 0
    var goToTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        lbTitle.text = kLb.about_meta.localized
        
        if let goToTitle = goToTitle, goToTitle != "" {
            for (index, item) in (appData.appSetting?.meta ?? []).enumerated() {
                if item.title == goToTitle {
                    self.goToTitle = ""
                    selectedIndex = index
                    tableView.reloadData()
                    break
                }
            }
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 0.01
        tableView.sectionFooterHeight = 0.01
        tableView.register(ProductDescTVC.self, forCellReuseIdentifier: "productDescTVC")
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension AboutMetaVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return appData.appSetting?.meta?.count ?? 0
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMetaTVC") as! AboutMetaTVC
            cell.lbTitle.text = appData.appSetting?.meta?[indexPath.row].title?.localized
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "productDescTVC") as! ProductDescTVC
            cell.webView.backgroundColor = .clear
            cell.lbTitle.isHidden = true
            cell.webView.navigationDelegate = self
            cell.webView.uiDelegate = self
            cell.setupWithoutTitle()
            cell.webView.loadHTMLString(appData.appSetting?.meta?[selectedIndex].htmlContent ?? "", baseURL: nil)
            cell.selectionStyle = .none
            cell.awakeFromNib()
            webTVC = cell
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            if let contentSize = webViewContentSize {
                return contentSize.height + 50
            }
        default:
            return UITableView.automaticDimension
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            webViewContentSize = CGSize.init(width: 0, height: 0)
            selectedIndex = indexPath.row
            
            webTVC.webView.loadHTMLString(appData.appSetting?.meta?[indexPath.row].htmlContent ?? "", baseURL: nil)
            
            //let cell = tableView.cellForRow(at: indexPath) as! AboutMetaTVC
            //cell.lbTitle.attributedText = NSAttributedString(string: appData.appSetting?.meta?[indexPath.row].title?.localized ?? "", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //let cell = tableView.cellForRow(at: indexPath) as! AboutMetaTVC
        }
    }
}

extension AboutMetaVC: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString.contains("") ?? false {
            webView.loadHTMLString("", baseURL: nil)
            deepLinkHandler(url: "metastones://create", navController: self.navigationController)
            
        } else {
            webView.webviewCorrector()
            if let height = webViewContentSize?.height, height <= CGFloat(0) {
                webView.evaluateJavaScript("document.readyState") { (complete, error) in
                    if complete != nil {
                        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                            self.webViewContentSize?.height = (height as! CGFloat)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
}

class AboutMetaTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
    }
}
