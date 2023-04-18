//
//  HtmlExtension.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import WebKit

extension WKWebView {
    func htmlCorrector() {
        //self.evaluateJavaScript(htmlHeaderCorrector())
        //self.evaluateJavaScript(htmlParagraphCorrector())
        //self.evaluateJavaScript(htmlSpanCorrector())
        //self.evaluateJavaScript(htmlBodyFontSizeCorrector())
        self.evaluateJavaScript(htmlTableCorrector(screenWidth: self.bounds.width))
        self.evaluateJavaScript(htmlImageCorrector(screenWidth: self.bounds.width))
        self.evaluateJavaScript(htmlVideoCorrector(screenWidth: self.bounds.width))
    }
    
    func webviewCorrector() {
        self.evaluateJavaScript(finalCorrector())
    }
    
    func loadHTMLStringWithDeviceWidth(content: String, baseURL: URL?){
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        loadHTMLString(headerString + content, baseURL: baseURL)
    }
}

private func finalCorrector() -> String {
    return "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
}

private func htmlBodyCorrector() -> String {
    return "document.getElementsByTagName('body')[0].style.padding ='30px'"
}

private func htmlBodyFontSizeCorrector() -> String {
    return "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='250%'"
}

private func htmlHeaderCorrector() -> String {
    let htmlContent = """
        var contents = document.getElementsByTagName(h1');
        var i;
        for(i=0;i<contents.length;i++){
          document.getElementsByTagName('h1')[i].style.fontFamily='-apple-system'
        }
        var contents = document.getElementsByTagName(h2');
        var i;
        for(i=0;i<contents.length;i++){
          document.getElementsByTagName('h2')[i].style.fontFamily='-apple-system'
        }

        """
    return htmlContent
}

private func htmlParagraphCorrector() -> String {
    let htmlContent = """
        var contents = document.getElementsByTagName('p');
        var i;
        for(i=0;i<contents.length;i++){
          document.getElementsByTagName('p')[i].style.fontFamily='-apple-system'
        }
        """
    return htmlContent
}

private func htmlImageCorrector(screenWidth: CGFloat) -> String {
    let htmlContent = """
    var contents = document.getElementsByTagName('img');
    var i;
    for(i=0;i<contents.length;i++){
    if(document.getElementsByTagName('img')[i].style.width > '\(screenWidth)'){
    document.getElementsByTagName('img')[i].style.width = '100%'
    }
    }
    """
    return htmlContent
}

private func htmlVideoCorrector(screenWidth: CGFloat) -> String {
    let htmlContent = """
    var contents = document.getElementsByTagName('video');
    var i;
    for(i=0;i<contents.length;i++){
    if(document.getElementsByTagName('video')[i].style.width > '\(screenWidth)'){
    document.getElementsByTagName('video')[i].style.width = '100%'
    }
    }
    """
    return htmlContent
}

private func htmlTableCorrector(screenWidth: CGFloat) -> String {
    let htmlContent = """
    var contents = document.getElementsByTagName('table');
    var i;
    for(i=0;i<contents.length;i++){
    if(document.getElementsByTagName('table')[i].style.width > '\(screenWidth)'){
    document.getElementsByTagName('table')[i].style.width = '100%'
    }
    }
    """
    return htmlContent
}

private func htmlSpanCorrector() -> String {
    let htmlContent = """
        var contents = document.getElementsByTagName('span');
        var i;
        for(i=0;i<contents.length;i++){
          document.getElementsByTagName('span')[i].style.fontFamily='-apple-system'
        }
        """
    return htmlContent
}

