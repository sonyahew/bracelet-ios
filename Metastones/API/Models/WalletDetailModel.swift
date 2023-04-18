//
//  WalletDetailModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct WalletDetailModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [WalletDetailDataModel?] = []
}

struct WalletDetailDataModel: HandyJSON, Codable {
    var ewalletTypeId: String?
    var ewalletTypeCode: String?
    var ewalletTypeName: String?
    var ewalletTypeDesc: String?
    var balance: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &ewalletTypeId, name: "ewallet_type_id")
        mapper.specify(property: &ewalletTypeCode, name: "ewallet_type_code")
        mapper.specify(property: &ewalletTypeName, name: "ewallet_type_name")
        mapper.specify(property: &ewalletTypeDesc, name: "ewallet_type_desc")
    }
}
