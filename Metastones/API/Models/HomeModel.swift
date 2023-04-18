//
//  HomeModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 15/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct HomeModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: HomeDataModel? = HomeDataModel.init()
}

struct HomeDataModel: HandyJSON, Codable {
    var product: ProductModel? = ProductModel.init()
    var banner: BannerModel? = BannerModel.init()
    var fbLive: [FBLiveModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &fbLive, name: "fb_live")
    }
}

struct ProductModel: HandyJSON, Codable {
    var newArrivalProducts: [ProductDataModel]?
    var suggestionProducts: [ProductDataModel]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &newArrivalProducts, name: "new_arrival_products")
        mapper.specify(property: &suggestionProducts, name: "suggestion_products")
    }
}

struct ProductDataModel: HandyJSON, Codable {
    var id: Int?
    var code: String?
    var name: String?
    var imgPath: String?
    var currentUnitPrice: String?
    var productName: String?
    var shortDesc: String?
    var lang: String?
    var new: Int?
    var normalUnitPrice: String?
    var discount: String?
    var rating: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &currentUnitPrice, name: "current_unit_price")
        mapper.specify(property: &productName, name: "product_name")
        mapper.specify(property: &shortDesc, name: "short_desc")
        mapper.specify(property: &normalUnitPrice, name: "normal_unit_price")
    }
}

struct BannerModel: HandyJSON, Codable {
    var header: [BannerDataModel]?
    var footer: [BannerDataModel]?
}

struct BannerDataModel: HandyJSON, Codable {
    var id: Int?
    var title: String?
    var caption: String?
    var imgPath: String?
    var seqNo: Int?
    var url: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &seqNo, name: "seq_no")
    }
}

struct FBLiveModel: HandyJSON, Codable {
    var fbLiveId: Int?
    var startDate: String?
    var endDate: String?
    var startTime: String?
    var endTime: String?
    var fbLiveLink: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &fbLiveId, name: "fb_live_id")
        mapper.specify(property: &startDate, name: "start_date")
        mapper.specify(property: &endDate, name: "end_date")
        mapper.specify(property: &startTime, name: "start_time")
        mapper.specify(property: &endTime, name: "end_time")
        mapper.specify(property: &fbLiveLink, name: "fb_live_link")
    }
}
