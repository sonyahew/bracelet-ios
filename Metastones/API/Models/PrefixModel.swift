//
//  PrefixModel.swift
//  Metastones
//
//  Created by Sonya Hew on 20/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct PrefixModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [PrefixDataModel]?
}

struct PrefixDataModel: HandyJSON, Codable {
    var countryId: Int?
    var code: String?
    var name: String?
    var prefixCallingCode: String?
    var imgPath: String?
    var mobileImgPath: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &countryId, name: "country_id")
        mapper.specify(property: &prefixCallingCode, name: "prefix_calling_code")
        mapper.specify(property: &imgPath, name: "image_path")
        mapper.specify(property: &mobileImgPath, name: "mobile_image_path")
    }
}
