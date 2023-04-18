//
//  MyWithdrawalModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 06/01/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct MyWithdrawalModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: MyWithdrawalDataModel? = MyWithdrawalDataModel.init()
}

struct MyWithdrawalDataModel: HandyJSON, Codable {
    var withdrawals: [MyWithdrawalSubdataModel?] = []
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

struct MyWithdrawalSubdataModel: HandyJSON, Codable {
    var id: Int?
    var transDate: String?
    var ewalletName: String?
    var transactionType: String?
    var totalAmount: String?
    var status: String?
    var statusDesc: String?
    var totalOut: String?
    var currencyCode: String?
    var docNo: String?
    var bankName: String?
    var ewalletTypeId: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &transDate, name: "trans_date")
        mapper.specify(property: &ewalletName, name: "ewallet_name")
        mapper.specify(property: &transactionType, name: "transaction_type")
        mapper.specify(property: &totalAmount, name: "total_amount")
        mapper.specify(property: &statusDesc, name: "status_desc")
        mapper.specify(property: &totalOut, name: "total_out")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &docNo, name: "doc_no")
        mapper.specify(property: &bankName, name: "bank_name")
        mapper.specify(property: &ewalletTypeId, name: "ewallet_type_id")
    }
}
