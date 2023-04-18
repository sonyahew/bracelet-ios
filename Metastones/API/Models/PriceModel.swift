//
//  PriceModel.swift
//  Metastones
//
//  Created by Sonya Hew on 19/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct PriceModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: PriceDataModel? = PriceDataModel.init()
}

struct PriceDataModel: HandyJSON, Codable {
    var qtyOnHand: QtyOnHandModel? = QtyOnHandModel.init()
    var currencyCode: String?
    var price: String?
    var prdQtyId: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &qtyOnHand, name: "qty_on_hand")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &prdQtyId, name: "prd_qty_id")
    }
}

struct QtyOnHandModel: HandyJSON, Codable {
    var error: Int?
    var msgType: String?
    var msg: String?
    var qtyOnHand: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &qtyOnHand, name: "qty_on_hand")
    }
}
