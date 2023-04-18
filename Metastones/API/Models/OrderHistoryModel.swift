//
//  OrderHistoryModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 21/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct OrderHistoryModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: OrderHistoryDataModel? = OrderHistoryDataModel.init()
}

struct OrderHistoryDataModel: HandyJSON, Codable {
    var transaction: [OrderHistorySubdataModel?] = []
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

struct OrderHistorySubdataModel: HandyJSON, Codable {
    var id: Int?
    var docNo: String?
    var displayDate: String?
    var totalAmount: String?
    var status: String?
    var shipAddrName: String?
    var billAddrName: String?
    var totalDelivery: String?
    var deliveryStatus: String?
    var subtotal: String?
    var totalQty: String?
    var totalDisc: String?
    var currencyCode: String?
    var shippingAddr: String?
    var billingAddr: String?
    var contact: String?
    var email: String?
    var statusDesc: String?
    var transactionType: String?
    var orderNo: String?
    var items: [OrderItemModel?] = []
    var payment: [WalletPaymentModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &docNo, name: "doc_no")
        mapper.specify(property: &displayDate, name: "display_date")
        mapper.specify(property: &totalAmount, name: "total_amount")
        mapper.specify(property: &totalDelivery, name: "total_delivery")
        mapper.specify(property: &deliveryStatus, name: "delivery_status")
        mapper.specify(property: &totalQty, name: "total_qty")
        mapper.specify(property: &totalDisc, name: "total_disc")
        mapper.specify(property: &subtotal, name: "sub_total")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &shipAddrName, name: "shipping_addr_name")
        mapper.specify(property: &billAddrName, name: "billing_addr_name")
        mapper.specify(property: &shippingAddr, name: "shipping_addr")
        mapper.specify(property: &billingAddr, name: "billing_addr")
        mapper.specify(property: &statusDesc, name: "status_desc")
        mapper.specify(property: &transactionType, name: "transaction_type")
        mapper.specify(property: &orderNo, name: "order_no")
    }
}

struct WalletPaymentModel: HandyJSON, Codable {
    var paymentType: String?
    var ewalletTypeCode: String?
    var ewalletTypeDesc: String?
    var paidAmount: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &paymentType, name: "payment_type")
        mapper.specify(property: &ewalletTypeCode, name: "ewallet_type_code")
        mapper.specify(property: &ewalletTypeDesc, name: "ewallet_type_desc")
        mapper.specify(property: &paidAmount, name: "paid_amount")
    }
}

struct OrderItemModel: HandyJSON, Codable {
    var qty: Int?
    var unitPrice: String?
    var totalAmount: String?
    var imgPath: String?
    var productName: String?
    var prdMasterId: Int?
    var currencyCode: String?
    var optionName: [String]?
    var seqNo: [Int]?
    var bead: [OrderItemModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &unitPrice, name: "unit_price")
        mapper.specify(property: &totalAmount, name: "total_amount")
        mapper.specify(property: &imgPath, name: "img_path")
        mapper.specify(property: &productName, name: "product_name")
        mapper.specify(property: &prdMasterId, name: "prd_master_id")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &optionName, name: "option_name")
        mapper.specify(property: &seqNo, name: "seq_no")
    }
}
