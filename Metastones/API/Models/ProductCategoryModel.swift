//
//  ProductCategoryModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct ProductCategoryModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [ProductCategoryModel?] = []
}

struct ProductCategoryModel: HandyJSON, Codable {
    var id: Int?
    var code: String?
    var name: String?
    var parentID: Int?
    var level: Int?
    var seqNo: Int?
    var children: [ProductCategoryModel]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &parentID, name: "parent_id")
        mapper.specify(property: &seqNo, name: "seq_no")
    }
}
