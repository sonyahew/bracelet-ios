//
//  SignupModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct SignupModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: SignupModel? = SignupModel.init()
}

struct SignupModel: HandyJSON, Codable {
    var token: String?
    var popupImage: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &popupImage, name: "popup_image")
    }
}
