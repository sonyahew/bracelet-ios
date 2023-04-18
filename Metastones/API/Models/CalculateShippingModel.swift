//
//  CalculateShippingModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 30/06/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import HandyJSON

struct CalculateShippingModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: CalculateShippingDataModel? = CalculateShippingDataModel.init()
}

struct CalculateShippingDataModel: HandyJSON, Codable {
    var shipping: [CheckoutShippingModel] = []
    var totalDisc: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &totalDisc, name: "total_disc")
    }
}
