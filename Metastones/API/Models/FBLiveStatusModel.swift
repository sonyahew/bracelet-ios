//
//  FBLiveStatusModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 05/03/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct FBLiveStatusModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: FBLiveStatusDataModel? = FBLiveStatusDataModel.init()
}

struct FBLiveStatusDataModel: HandyJSON, Codable {
    var currentLive: FBLiveModel? = FBLiveModel.init()
    var fbLiveList: [FBLiveModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &currentLive, name: "current_live")
        mapper.specify(property: &fbLiveList, name: "fb_live_list")
    }
}
