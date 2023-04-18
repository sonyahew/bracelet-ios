//
//  PaymentPageModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 27/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct PaymentPageModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: PaymentPageDataModel? = PaymentPageDataModel.init()
}

struct PaymentPageDataModel: HandyJSON, Codable {
    var paymentPage: String?
    var url: String?
    var redirectUrl: String?
    var checkoutId: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &paymentPage, name: "payment_page")
        mapper.specify(property: &redirectUrl, name: "redirect_url")
        mapper.specify(property: &checkoutId, name: "checkout_id")
    }
}
