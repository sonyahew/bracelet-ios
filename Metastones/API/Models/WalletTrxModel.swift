//
//  WalletTrxModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 20/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct WalletTrxModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: WalletTrxDataModel? = WalletTrxDataModel.init()
}

struct WalletTrxDataModel: HandyJSON, Codable {
    var transaction: [WalletTrxSubdataModel?] = []
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

struct WalletTrxSubdataModel: HandyJSON, Codable {
    var id: Int?
    var ewalletTypeCode: String?
    var ewalletType: String?
    var transDate: String?
    var totalIn: String?
    var totalOut: String?
    var description: String?
    var status: String?
    var amountValue: String?
    var docNo: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &ewalletTypeCode, name: "ewallet_type_code")
        mapper.specify(property: &ewalletType, name: "ewallet_type")
        mapper.specify(property: &transDate, name: "trans_date")
        mapper.specify(property: &totalIn, name: "total_in")
        mapper.specify(property: &totalOut, name: "total_out")
        mapper.specify(property: &amountValue, name: "amount")
        mapper.specify(property: &docNo, name: "doc_no")
    }
}
