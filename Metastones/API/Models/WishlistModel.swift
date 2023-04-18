//
//  WishlistModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct WishlistModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [WishlistDataModel?] = []
}

struct WishlistDataModel: HandyJSON, Codable {
    var id: Int?
    var prdMasterId: Int?
    var prdType: String?
    var code: String?
    var imgPath: String?
    var unitPrice: String?
    var discount: String?
    var qty: Int?
    var subtotal: String?
    var totalAmount: String?
    var status: String?
    var name: String?
    var prdUrl: String?
    var currencyCode: String?
    var minPrice: String?
    var maxPrice: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &prdMasterId, name: "prd_master_id")
        mapper.specify(property: &prdType, name: "prd_type")
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &unitPrice, name: "unit_price")
        mapper.specify(property: &subtotal, name: "sub_total")
        mapper.specify(property: &totalAmount, name: "total_amount")
        mapper.specify(property: &prdUrl, name: "prd_url")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &minPrice, name: "min_price")
        mapper.specify(property: &maxPrice, name: "max_price")
        mapper.specify(property: &name, name: "product_name")
    }
}
