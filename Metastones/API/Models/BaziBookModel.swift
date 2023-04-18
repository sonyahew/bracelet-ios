//
//  BaziBookModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct BaziBookModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [BaziBookDataModel?] = []
}

struct BaziBookDataModel: HandyJSON, Codable {
    var id: Int?
    var defaultBz: Int?
    var name: String?
    var birthDate: String?
    var gender: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &defaultBz, name: "default_bz")
        mapper.specify(property: &birthDate, name: "birth_date")
    }
}
