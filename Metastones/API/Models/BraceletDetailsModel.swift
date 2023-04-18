//
//  BraceletDetailsModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 07/01/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct BraceletDetailsModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: BraceletDetailsDataModel? = BraceletDetailsDataModel.init()
}

struct BraceletDetailsDataModel: HandyJSON, Codable {
    var numberBaziBead: NumberBaziBeadModel? = NumberBaziBeadModel.init()
    var bracelet: [BraceletBeadModel?] = []
    var bead: BeadDataModel? = BeadDataModel.init()
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &numberBaziBead, name: "number_bazi_bead")
    }
}

struct NumberBaziBeadModel: HandyJSON, Codable {
    var metal: Int?
    var wood: Int?
    var water: Int?
    var fire: Int?
    var earth: Int?
}

struct BeadDataModel: HandyJSON, Codable {
    var metal: [BraceletBeadModel?] = []
    var wood: [BraceletBeadModel?] = []
    var water: [BraceletBeadModel?] = []
    var fire: [BraceletBeadModel?] = []
    var earth: [BraceletBeadModel?] = []
}

struct BraceletBeadModel: HandyJSON, Codable {
    var id: String?
    var qtyId: String?
    var name: String?
    var size: String?
    var currencyCode: String?
    var unitPrice: String?
    var path: String?
    var type: String?
    
    var quantity: Int = 1
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &qtyId, name: "qty_id")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &unitPrice, name: "unit_price")
    }
}

struct PostCustomBraceletModel: HandyJSON, Codable {
    var prd_master_id: String = ""
    var prd_qty_id: String = ""
    var qty: Int = 0
    var seq_no: [Int]?
    var currency_code: String = ""
}

struct ToPostCustomBraceletModel: HandyJSON, Codable {
    var data: [PostCustomBraceletModel?] = []
}

