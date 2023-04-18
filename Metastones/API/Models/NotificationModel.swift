//
//  NotificationModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct NotificationModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: NotificationDataModel? = NotificationDataModel.init()
}

struct NotificationDataModel: HandyJSON, Codable {
    var notification: [NotificationSubdataModel?] = []
    var currentPage: Int?
    var itemPerPage: Int?
    var total: Int?
    var lastPage: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &currentPage, name: "current_page")
        mapper.specify(property: &itemPerPage, name: "item_per_page")
        mapper.specify(property: &lastPage, name: "last_page")
    }
}

struct NotificationSubdataModel: HandyJSON, Codable {
    var id: Int?
    var dateAdded: String?
    var title: String?
    var desc: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &dateAdded, name: "date_added")
    }
}
