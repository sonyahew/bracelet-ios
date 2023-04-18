//
//  CalculateBzModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 18/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct CalculateBzModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: CalculateBzDataModel? = CalculateBzDataModel.init()
}

struct CalculateBzDataModel: HandyJSON, Codable {
    var bazi: BaziDataModel? = BaziDataModel.init()
    var colorBalance: ColorBalanceDataModel? = ColorBalanceDataModel.init()
    var suggestedProduct: [ProductListDataModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &colorBalance, name: "color_balance")
        mapper.specify(property: &suggestedProduct, name: "suggested_product")
    }
}

struct BaziDataModel: HandyJSON, Codable {
    var year: [String]?
    var month: [String]?
    var day: [String]?
    var time: [String]?
}

struct ColorBalanceDataModel: HandyJSON, Codable {
    var metal: Double?
    var wood: Double?
    var water: Double?
    var fire: Double?
    var earth: Double?
}
