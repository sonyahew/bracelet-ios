//
//  TranslationModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct TranslationModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [TranslationDataModel?] = []
}

struct TranslationDataModel: HandyJSON, Codable {
    var ID: Int?
    var langID: String?
    var transID: String?
    var transDesc: String?
}
