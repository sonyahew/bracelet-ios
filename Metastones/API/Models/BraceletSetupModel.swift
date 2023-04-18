//
//  BraceletSetupModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 06/01/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct BraceletSetupModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [BraceletSetupDataModel?] = []
}

struct BraceletSetupDataModel: HandyJSON, Codable {
    var braceletSize: Int?
    var braceletDesc: String?
    var beadSize: [Int?] = []
    var numberBead: [Int?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &braceletSize, name: "bracelet_size")
        mapper.specify(property: &braceletDesc, name: "bracelet_desc")
        mapper.specify(property: &beadSize, name: "bead_size")
        mapper.specify(property: &numberBead, name: "number_bead")
    }
}
