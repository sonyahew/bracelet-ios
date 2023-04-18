//
//  ProfileModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 19/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct ProfileModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: ProfileDataModel? = ProfileDataModel.init()
}

struct ProfileDataModel: HandyJSON, Codable {
    var profile: ProfileDetailModel? = ProfileDetailModel.init()
    var addr: [ProfileAddrModel?] = []
    var reward: [ProfileRewardModel?] = []
    var welcomeVoucher: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &welcomeVoucher, name: "welcome_voucher")
    }
}

struct ProfileDetailModel: HandyJSON, Codable {
    var id: Int?
    var nickName: String?
    var email: String?
    var mobileNo: String?
    var birthDate: String?
    var gender: String?
    var statusDesc: String?
    var fullName: String?
    var avatar: String?
    var imgPath: String?
    var qrPath: String?
    var replicatorName: String?
    var memberType: String?
    var upgradeMem: Int?
    var welcomePoint: Int?
    var mobilePoint: Int?
    var notification: Int?
    var referralUrl: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &nickName, name: "nick_name")
        mapper.specify(property: &mobileNo, name: "mobile_no")
        mapper.specify(property: &birthDate, name: "birth_date")
        mapper.specify(property: &statusDesc, name: "status_desc")
        mapper.specify(property: &fullName, name: "full_name")
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &qrPath, name: "qr_path")
        mapper.specify(property: &replicatorName, name: "replicator_name")
        mapper.specify(property: &memberType, name: "member_type")
        mapper.specify(property: &upgradeMem, name: "upgrade_mem")
        mapper.specify(property: &welcomePoint, name: "welcome_point")
        mapper.specify(property: &mobilePoint, name: "mobile_point")
        mapper.specify(property: &referralUrl, name: "referral_url")
    }
}

struct ProfileAddrModel: HandyJSON, Codable {
    var id: Int?
    var memberId: String?
    var displayAddrName: String?
    var displayAddrEmail: String?
    var contactNo: String?
    var prefixCallingCode: String?
    var contactDesc: String?
    var addr1: String?
    var cityId: Int?
    var city: String?
    var state: String?
    var countryId: Int?
    var zip: String?
    var defaultBilling: Int?
    var defaultShipping: Int?
    var status: String?
    var stateId: Int?
    var stateCode: Int?
    var cityDesc: String?
    var stateDesc: String?
    var countryCode: String?
    var countryDesc: String?
    var name: String?
    var email: String?
    var mobileNo: String?
    var address: String?
    var address2: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &memberId, name: "member_id")
        mapper.specify(property: &displayAddrName, name: "display_addr_name")
        mapper.specify(property: &displayAddrEmail, name: "display_addr_email")
        mapper.specify(property: &contactNo, name: "contact_no")
        mapper.specify(property: &prefixCallingCode, name: "prefix_calling_code")
        mapper.specify(property: &contactDesc, name: "contact_desc")
        mapper.specify(property: &cityId, name: "city_id")
        mapper.specify(property: &countryId, name: "country_id")
        mapper.specify(property: &defaultBilling, name: "default_billing")
        mapper.specify(property: &defaultShipping, name: "default_shipping")
        mapper.specify(property: &stateId, name: "state_id")
        mapper.specify(property: &stateCode, name: "state_code")
        mapper.specify(property: &cityDesc, name: "city")
        mapper.specify(property: &stateDesc, name: "state_desc")
        mapper.specify(property: &countryCode, name: "country_code")
        mapper.specify(property: &countryDesc, name: "country_desc")
        mapper.specify(property: &mobileNo, name: "mobile_no")
        
    }
}

struct ProfileRewardModel: HandyJSON, Codable {
    var type: String?
    var point: String?
}
