//
//  WithdrawalModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 30/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct WithdrawalModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: WithdrawalDataModel? = WithdrawalDataModel.init()
}

struct WithdrawalDataModel: HandyJSON, Codable  {
    var ewalletTypeName: String?
    var ewalletTypeId: Int?
    var balance: String?
    var currencyCode: String?
    var processingFee: String?
    var minimumAmount: String?
    var maximumAmount: String?
    var withdrawalPolicy: String?
    var bankList: [WithdrawalBankListModel?] = []
    var memberBank: WithdrawalMemberBankModel? = WithdrawalMemberBankModel.init()
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &ewalletTypeName, name: "ewallet_type_name")
        mapper.specify(property: &ewalletTypeId, name: "ewallet_type_id")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &processingFee, name: "processing_fee")
        mapper.specify(property: &minimumAmount, name: "minimum_amount")
        mapper.specify(property: &maximumAmount, name: "maximum_amount")
        mapper.specify(property: &withdrawalPolicy, name: "withdrawal_policy")
        mapper.specify(property: &bankList, name: "bank_list")
        mapper.specify(property: &memberBank, name: "member_bank")
    }
}

struct WithdrawalBankListModel: HandyJSON, Codable  {
    var id: Int?
    var countryId: Int?
    var code: String?
    var name: String?
    var accNoLength: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &countryId, name: "country_id")
        mapper.specify(property: &accNoLength, name: "acc_no_length")
    }
}

struct WithdrawalMemberBankModel: HandyJSON, Codable  {
    var id: Int?
    var bankTypeId: Int?
    var bankAccNo: String?
    var bankAccName: String?
    var bankAccMobileNo: String?
    var bankAccEmail: String?
    var bankAccNric: String?
    var bankAccMobilePrefixNo: String?
    var avatar: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &bankTypeId, name: "bank_type_id")
        mapper.specify(property: &bankAccNo, name: "bank_acc_no")
        mapper.specify(property: &bankAccName, name: "bank_acc_name")
        mapper.specify(property: &bankAccMobileNo, name: "bank_acc_mobile_no")
        mapper.specify(property: &bankAccEmail, name: "bank_acc_email")
        mapper.specify(property: &bankAccNric, name: "bank_acc_nric")
        mapper.specify(property: &bankAccMobilePrefixNo, name: "bank_acc_mobile_prefix_no")
    }
}
