//
//  OTPModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct OTPModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: OTPModel? = OTPModel.init()
}

struct OTPModel: HandyJSON, Codable {
    var success: String?
    var otp: String?
    var token: String?
    var timeout: String?
    var mobileNo: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &mobileNo, name: "mobile_no")
    }
}
