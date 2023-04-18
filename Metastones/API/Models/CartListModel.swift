//
//  CartListModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 23/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct CartListModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: CartListDataModel? = CartListDataModel.init()
}

struct CartListDataModel: HandyJSON, Codable {
    var totalItems: Int?
    var currencyCode: String?
    var subTotal: String?
    var totalAmount: String?
    var products: [CartItemModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &totalItems, name: "total_items")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &subTotal, name: "sub_total")
        mapper.specify(property: &totalAmount, name: "total_amount")
    }
}

struct CartItemModel: HandyJSON, Codable {
    var prdCartId: Int?
    var prdMasterId: Int?
    var code: String?
    var productName: String?
    var optionId: String?
    var imgPath: String?
    var currencyCode: String?
    var unitPrice: String?
    var oriUnitPrice: String?
    var discount: String?
    var voucher: Int?
    var qty: Int?
    var totalAmount: String?
    var status: String?
    var checked: Int?
    var validity: String?
    var weight: String?
    var domestic: Int?
    var international: Int?
    var returnP: Int?
    var exchange: Int?
    var warranty: Int?
    var refund: Int?
    var prdType: String?
    var groupId: String?
    var optionName: [String]?
    var bead: [CartItemModel]?
    var seqNo: [Int]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &prdCartId, name: "prd_cart_id")
        mapper.specify(property: &prdMasterId, name: "prd_master_id")
        mapper.specify(property: &productName, name: "product_name")
        mapper.specify(property: &optionId, name: "option_id")
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &unitPrice, name: "unit_price")
        mapper.specify(property: &oriUnitPrice, name: "ori_unit_price")
        mapper.specify(property: &totalAmount, name: "total_amount")
        mapper.specify(property: &returnP, name: "return_p")
        mapper.specify(property: &optionName, name: "option_name")
        mapper.specify(property: &prdType, name: "prd_type")
        mapper.specify(property: &seqNo, name: "seq_no")
        mapper.specify(property: &groupId, name: "group_id")
    }
}
