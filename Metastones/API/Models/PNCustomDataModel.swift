//
//  PNCustomDataModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct PNCustomDataModel: HandyJSON, Codable {
    var key: String?
    var quoteId: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &quoteId, name: "quote_id")
    }
}
