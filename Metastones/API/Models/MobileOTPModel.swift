//
//  OTPModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 31/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct MobileOTPModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: MobileOTPDataModel? = MobileOTPDataModel.init()
}

struct MobileOTPDataModel: HandyJSON, Codable  {
    var validTime: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &validTime, name: "valid_time")
    }
}
