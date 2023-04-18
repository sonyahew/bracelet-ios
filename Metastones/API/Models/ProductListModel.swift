//
//  ProductListModel.swift
//  Metastones
//
//  Created by Sonya Hew on 17/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct ProductListModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: ProductListModel? = ProductListModel.init()
}

struct ProductListModel: HandyJSON, Codable {
    var products: [ProductListDataModel]?
    var currentPage: Int?
    var itemPerPage: Int?
    var total: Int?
    var lastPage: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &currentPage, name: "current_page")
        mapper.specify(property: &itemPerPage, name: "item_per_page")
        mapper.specify(property: &lastPage, name: "last_page")
    }
}

struct ProductListDataModel: HandyJSON, Codable {
    var id: Int?
    var code: String?
    var name: String?
    var imgPath: String?
    var currencyCode: String?
    var currentUnitPrice: String?
    var productName: String?
    var shortDesc: String?
    var lang: String?
    var new: Int?
    var bestSeller: Int?
    var wishlist: Int?
    var prdType: String?
    
    var isWishlist: Bool {
        get {
            return wishlist ?? 0 == 1
        }
    }

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &currentUnitPrice, name: "current_unit_price")
        mapper.specify(property: &productName, name: "product_name")
        mapper.specify(property: &shortDesc, name: "short_desc")
        mapper.specify(property: &bestSeller, name: "best_seller")
        mapper.specify(property: &prdType, name: "prd_type")
    }
}
