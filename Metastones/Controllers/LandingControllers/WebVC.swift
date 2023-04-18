//
//  WebVC.swift
//  Metastones
//
//  Created by Sonya Hew on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vwWebview: UIView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var strUrl: String? = ""
    var strHtml: String? = ""
    var wvContent: WKWebView!
    var vcTitle: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        wvContent = WKWebView(frame: .zero, configuration: webConfiguration)
        
        wvContent.uiDelegate = self
        wvContent.navigationDelegate = self
        aiLoading.hidesWhenStopped = true
        lbTitle.text = vcTitle
        
        // Do any additional setup after loading the view.
        if let strHtml = strHtml, strHtml != "" {
            wvContent.loadHTMLString(strHtml, baseURL: nil)
            
        } else if let strUrl = strUrl, strUrl != "", let url = URL.init(string: strUrl) {
            wvContent.load(URLRequest.init(url: url))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wvContent.frame = vwWebview.bounds
        vwWebview.addSubview(wvContent)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.wvContent.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    @IBAction func backHandler(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension WebVC: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            openUrl(url: navigationAction.request.url?.absoluteString)
            decisionHandler(.cancel)
            
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        aiLoading.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.webviewCorrector()
        aiLoading.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        aiLoading.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        aiLoading.stopAnimating()
    }
}
