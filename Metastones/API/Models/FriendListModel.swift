//
//  FriendListModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct FriendListModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: [FriendListDataModel?] = []
}

struct FriendListDataModel: HandyJSON, Codable {
    var name: String?
    var imgPath: String?
    var contactDesc: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &contactDesc, name: "contact_desc")
    }
}
