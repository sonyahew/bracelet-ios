//
//  AppSettingModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct AppSettingModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: AppSettingDataModel = AppSettingDataModel.init()
}

struct AppSettingDataModel: HandyJSON, Codable {
    var shippingGuide: AppSettingSubdataModel?
    var returnPolicy: AppSettingSubdataModel?
    var terms: AppSettingSubdataModel?
    var privacyPolicy: AppSettingSubdataModel?
    var aboutUs: AppSettingSubdataModel?
    var disclaimer: AppSettingSubdataModel?
    var faq: AppSettingSubdataModel?
    var highlights: [AppSettingContentModel]?
    var shareEarn: AppSettingSubdataModel?
    var checkout: Int?
    var customBraceletCheckout: Int?
    var meta: [AppSettingContentModel]?
    var popup: [AppSettingContentModel]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &shippingGuide, name: "shipping_guide")
        mapper.specify(property: &returnPolicy, name: "return_exchange_refund_policy")
        mapper.specify(property: &terms, name: "terms_and_conditions")
        mapper.specify(property: &privacyPolicy, name: "privacy_policy")
        mapper.specify(property: &aboutUs, name: "about_us")
        mapper.specify(property: &shareEarn, name: "share_&_earn")
        mapper.specify(property: &customBraceletCheckout, name: "customize")
    }
}

struct AppSettingSubdataModel: HandyJSON, Codable {
    var url: String?
    var htmlContent: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &htmlContent, name: "html_content")
    }
}

struct AppSettingContentModel: HandyJSON, Codable {
    var title: String?
    var url: String?
    var htmlContent: String?
    var imgPath: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &htmlContent, name: "html_content")
        mapper.specify(property: &imgPath, name: "img_path")
    }
}
