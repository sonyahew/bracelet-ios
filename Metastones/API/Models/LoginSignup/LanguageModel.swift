//
//  LanguageModel.swift
//  Metastones
//
//  Created by Sonya Hew on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct LanguageModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: LanguageModel? = LanguageModel.init()
}

struct LanguageModel: HandyJSON, Codable {
    var language: [LanguageDataModel]?
}

struct LanguageDataModel: HandyJSON, Codable {
    var id: String?
    var locale: String?
    var localeName: String?
    var name: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &localeName, name: "locale_name")
    }
}

