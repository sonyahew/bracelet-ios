//
//  APIBaseModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct APIBaseModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
}
