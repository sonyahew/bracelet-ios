//
//  CheckoutModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 25/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct CheckoutModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: CheckoutDataModel? = CheckoutDataModel.init()
}

struct CheckoutDataModel: HandyJSON, Codable {
    var defaultShipping: [ProfileAddrModel?] = []
    var defaultBilling: [ProfileAddrModel?] = []
    var ewallet: [CheckoutEwalletModel?] = []
    var cart: CheckoutCartModel? = CheckoutCartModel.init()
    var shippingFee: [CheckoutShippingModel] = []
    var voucher: [CheckoutVoucherModel?] = []
    var message: String?
    var freeShipping: Int?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &defaultShipping, name: "default_shipping")
        mapper.specify(property: &defaultBilling, name: "default_billing")
        mapper.specify(property: &shippingFee, name: "shipping_fee")
        mapper.specify(property: &freeShipping, name: "free_shipping")
    }
}

struct CheckoutEwalletModel: HandyJSON, Codable {
    var unit: Int?
    var rate: Int?
    var balance: Double?
    var ewalletTypeId: Int?
    var ewalletTypeDesc: String?
    var ewalletTypeName: String?
    var ewalletTypeCode: String?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &ewalletTypeId, name: "ewallet_type_id")
        mapper.specify(property: &ewalletTypeDesc, name: "ewallet_type_desc")
        mapper.specify(property: &ewalletTypeName, name: "ewallet_type_name")
        mapper.specify(property: &ewalletTypeCode, name: "ewallet_type_code")
    }
}

struct CheckoutCartModel: HandyJSON, Codable {
    var totalItems: Int?
    var currencyCode: String?
    var subTotal: String?
    var totalAmount: String?
    var products: [CartItemModel?] = []
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &totalItems, name: "total_items")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &subTotal, name: "sub_total")
        mapper.specify(property: &totalAmount, name: "total_amount")
    }
}

struct CheckoutVoucherModel: HandyJSON, Codable {
    var id: Int?
    var voucherCode: String?
    var voucherDesc: String?
    var currencyCode: String?
    var minSpend: String?
    var maxSpend: String?
    var amountDisc: String?
    var startDate: String?
    var endDate: String?
    var validity: String?
    var discountType: String?
    var percentDisc: Int?
    var eligibility: Int?
    
    var selected: Bool = false
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &voucherCode, name: "voucher_code")
        mapper.specify(property: &voucherDesc, name: "voucher_desc")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &minSpend, name: "min_spend")
        mapper.specify(property: &maxSpend, name: "max_spend")
        mapper.specify(property: &amountDisc, name: "amount_disc")
        mapper.specify(property: &startDate, name: "start_date")
        mapper.specify(property: &endDate, name: "end_date")
        mapper.specify(property: &discountType, name: "disc_type")
        mapper.specify(property: &percentDisc, name: "percent_disc")
    }
}

struct CheckoutShippingModel: HandyJSON, Codable {
    var courierId: String?
    var serviceId: String?
    var logo: String?
    var company, delivery, shipmentPrice, serviceDetail: String?
    var currencyCode: String?
    
    var selected: Bool = false
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &courierId, name: "courier_id")
        mapper.specify(property: &serviceId, name: "service_id")
        mapper.specify(property: &shipmentPrice, name: "shipment_price")
        mapper.specify(property: &currencyCode, name: "currency_code")
        mapper.specify(property: &serviceDetail, name: "service_detail")
    }
}
