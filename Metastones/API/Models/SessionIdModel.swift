//
//  SessionIdModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 29/06/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct SessionIdModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: SessionIdDataModel? = SessionIdDataModel.init()
}

struct SessionIdDataModel: HandyJSON, Codable {
    var sessionId: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &sessionId, name: "session_id")
    }
}
