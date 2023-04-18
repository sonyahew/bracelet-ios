//
//  CityStateModel.swift
//  Metastones
//
//  Created by Sonya Hew on 19/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct CityStateModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [CityStateDataModel]?
}

struct CityStateDataModel: HandyJSON, Codable {
    var id: Int?
    var code: String?
    var name: String?
}
