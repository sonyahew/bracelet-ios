//
//  ProductDetailsModel.swift
//  Metastones
//
//  Created by Sonya Hew on 18/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct ProductDetailsModule: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: ProductDetailsDataModel? = ProductDetailsDataModel.init()
}

struct ProductDetailsDataModel: HandyJSON, Codable {
    var product: ProductDetailsModel?
    var options: [OptionsModel]?
    var images: [ImageModel]?
    var price: PriceModel?
    var review: ReviewModel?
    var priceRange: PriceRangeDataModel?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &priceRange, name: "price_range")
    }
}

struct ImageModel: HandyJSON, Codable {
    var imgPath: String?
    var label: String?
    var video, videoImg, defaultImg: Int?
    var imageOptChoices, imageOptNames: String?

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &videoImg, name: "video_img")
        mapper.specify(property: &defaultImg, name: "default_img")
        mapper.specify(property: &imageOptChoices, name: "image_opt_choices")
        mapper.specify(property: &imageOptNames, name: "image_opt_names")
    }
}

struct OptionsModel: HandyJSON, Codable {
    var title: String?
    var option: [OptionsDataModel]?
}

struct OptionsDataModel: HandyJSON, Codable {
    var code: Int?
    var desc: String?
}

struct PriceModel: HandyJSON, Codable {
    var name: String?
    var currencyCode: String?
    var unitPrice: String?
    var prdQtyID: Int?
    var optionID: String?

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &unitPrice, name: "unit_price")
        mapper.specify(property: &prdQtyID, name: "prd_qty_id")
        mapper.specify(property: &optionID, name: "option_id")
    }
}

struct ProductDetailsModel: HandyJSON, Codable {
    var id: Int?
    var code: String?
    var name: String?
    var optionChoices: String?
    var discount: String?
    var productName: String?
    var shortDesc: String?
    var longDesc: String?
    var wishlist: Int?
    var bestSeller: Int?
    var prdType: String?
    var url: String?
    
    var isWishlist: Bool {
        get {
            return wishlist ?? 0 == 1
        }
    }
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &optionChoices, name: "option_choices")
        mapper.specify(property: &productName, name: "product_name")
        mapper.specify(property: &shortDesc, name: "short_desc")
        mapper.specify(property: &longDesc, name: "long_desc")
        mapper.specify(property: &bestSeller, name: "best_seller")
        mapper.specify(property: &prdType, name: "prd_type")
    }
}

struct ReviewModel: HandyJSON, Codable {
    var reviews: [ReviewDataModel]?
    var totalReviews: Int?
    var averageRating: String?
    var rounddownRating: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &totalReviews, name: "total_reviews")
        mapper.specify(property: &averageRating, name: "average_rating")
        mapper.specify(property: &rounddownRating, name: "rounddown_rating")
    }
}

struct ReviewDataModel: HandyJSON, Codable {
    var nickName: String?
    var memberImgPath: String?
    var rating: Int?
    var review: String?
    var createdAt: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &nickName, name: "nick_name")
        mapper.specify(property: &memberImgPath, name: "member_img_path")
        mapper.specify(property: &createdAt, name: "created_at")
    }
}

 struct PriceRangeDataModel: HandyJSON, Codable {
     var currencyCode: String?
     var minPrice: String?
     var maxPrice: String?
     
     mutating func mapping(mapper: HelpingMapper) {
         mapper.specify(property: &currencyCode, name: "currency_code")
         mapper.specify(property: &minPrice, name: "min_price")
         mapper.specify(property: &maxPrice, name: "max_price")
     }
 }
