//
//  LoginModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct LoginModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: LoginModel? = LoginModel.init()
}

struct LoginModel: HandyJSON, Codable {
    var token: String?
    var popupImage: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &popupImage, name: "popup_image")
    }
}
