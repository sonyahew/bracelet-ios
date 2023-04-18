//
//  PaymentGatewayVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 27/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import WebKit

class PaymentGatewayVC: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vwWebview: UIView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var wvContent: WKWebView!
    var paymentData: PaymentPageDataModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        wvContent = WKWebView(frame: .zero, configuration: webConfiguration)
        
        wvContent.uiDelegate = self
        wvContent.navigationDelegate = self
        aiLoading.hidesWhenStopped = true
        lbTitle.text = kLb.payment_gateway.localized
        
        // Do any additional setup after loading the view.
        if let strUrl = paymentData?.url, strUrl != "", let url = URL.init(string: strUrl), let postData = paymentData?.paymentPage {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData.data(using: .ascii, allowLossyConversion: true)
            wvContent.load(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wvContent.frame = vwWebview.bounds
        vwWebview.addSubview(wvContent)
    }
    
    @IBAction func backHandler(_ sender: Any) {
        backNavigation()
    }
    
    func backNavigation() {
        let deliveryAddrVC = getViewControllerFromStackFor(viewController: DeliveryVC(), currVC: self) as! DeliveryVC
        deliveryAddrVC.isCheckOrderStatus = true
        navigationController?.popToViewController(deliveryAddrVC, animated: true)
    }
}

extension PaymentGatewayVC: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        aiLoading.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let redirectUrl = paymentData?.redirectUrl, webView.url?.absoluteString.contains(redirectUrl) ?? false {
            backNavigation()
        }
        
        webView.webviewCorrector()
        aiLoading.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        aiLoading.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        aiLoading.stopAnimating()
    }
}
