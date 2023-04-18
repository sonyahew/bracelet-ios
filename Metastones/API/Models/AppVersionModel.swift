//
//  AppVersionModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct AppVersionModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: AppVersionDataModel? = AppVersionDataModel.init()
}

struct AppVersionDataModel: HandyJSON, Codable  {
    var id: Int?
    var platform: String?
    var maintenance: Int?
    var appVers: String?
    var storeUrl: String?
    var websiteUrl: String?
    var maintenanceMsg: String?
    var update: Int?
    var updateMsg: String?
}
