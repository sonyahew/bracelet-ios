//
//  DailyQuoteModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct DailyQuoteModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: DailyQuoteDataModel? = DailyQuoteDataModel.init()
}

struct DailyQuoteDataModel: HandyJSON, Codable  {
    var noticeDate: String?
    var noticeTime: String?
    var description: String?
    var imgPath: String?
    var url: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &noticeDate, name: "notice_date")
        mapper.specify(property: &noticeTime, name: "notice_time")
        mapper.specify(property: &imgPath, name: "img_path")
    }
}
