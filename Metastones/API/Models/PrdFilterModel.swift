//
//  PrdFilterModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 13/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct PrdFilterModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [PrdFilterDataModel?] = []
}

struct PrdFilterDataModel: HandyJSON, Codable  {
    var optName: String?
    var optValue: [PrdFilterSubdataModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &optName, name: "opt_name")
        mapper.specify(property: &optValue, name: "opt_value")
    }
}

struct PrdFilterSubdataModel: HandyJSON, Codable  {
    var optChoice: String?
    var code: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &optChoice, name: "opt_choice")
    }
}
