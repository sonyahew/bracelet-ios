//
//  CartViewModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 23/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class CartViewModel: ViewModelBase {
    func addCart(type: String? = nil, prdId: String? = nil, qty: String? = nil, optionId: String? = nil, prdCartId: String? = nil, checked: String? = nil, prdType: String? = nil, groupId: String? = nil, completion: @escaping (Bool, CartListModel?) -> Void) {
        
        var bodyData: [String: Any] = [:]
        
        if let prdCartId = prdCartId {
            if let checked = checked {
                //Check & uncheck product
                bodyData = [
                    "prd_cart_id": prdCartId,
                    "checked": checked,
                    "prd_type": prdType ?? "",
                    "group_id": groupId ?? "",
                    "lang_code": appData.data?.langId ?? ""
                ]
                
            } else if let qty = qty {
                //Update quantity
                bodyData = [
                    "prd_cart_id": prdCartId,
                    "qty": qty,
                    "prd_id": prdId ?? "",
                    "option_id": optionId ?? "",
                    "prd_type": prdType ?? "",
                    "lang_code": appData.data?.langId ?? ""
                ]
                
            } else if let type = type {
                //Remove product
                bodyData = [
                    "prd_cart_id": prdCartId,
                    "type": type,
                    "prd_type": prdType ?? "",
                    "group_id": groupId ?? "",
                    "lang_code": appData.data?.langId ?? ""
                ]
            }
            
        } else {
            //Add product
            bodyData = [
                "type": type ?? "",
                "prd_id": prdId ?? "",
                "qty": qty ?? "",
                "option_id": optionId ?? "",
                "prd_cart_id": prdCartId ?? "",
                "checked": checked ?? "",
                "prd_type": prdType ?? "",
                "lang_code": appData.data?.langId ?? ""
            ]
        }
        
        let request = apiManager.getRequest(urlPath: "api/add-cart", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: CartListModel.self, isShowError: true) { (proceed, data) in
            if proceed {
                self.getCart { (proceed, data) in }
            }
            completion(proceed, data)
        }
    }
    
    func getCart(completion: @escaping (Bool, CartListModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/my-cart?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: CartListModel.self, isShowError: true) { (proceed, data) in
            if proceed {
                self.appData.data?.cartItemCount = data?.data?.products.count
            }
            completion(proceed, data)
        }
    }
    
    func checkout(prdId: Int? = nil, prdType: String? = nil, completion: @escaping (Bool, CheckoutModel?) -> Void) {
        
        var bodyData: [String: Any] = [:]
        
        if let prdId = prdId, let prdType = prdType {
            bodyData = [
                "prd_id": prdId ,
                "prd_type": prdType,
                "lang_code": appData.data?.langId ?? ""
            ]
        } else {
            bodyData = [
                "lang_code": appData.data?.langId ?? ""
            ]
        }
        let request = apiManager.getRequest(urlPath: "api/checkout", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: CheckoutModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getPaymentPage(ewalletTypeId: [Int?]? = nil, payAmount: [String]? = nil, totalAmount: String? = nil, courier: CheckoutShippingModel? = nil, shippingAddrId: Int? = nil, billingAddrId: Int? = nil, voucherCode: String? = nil, totalDisc: String? = nil, prdId: Int? = nil, prdType: String? = nil, completion: @escaping (Bool, PaymentPageModel?) -> Void) {
        
        let paymentMethod = ["ewallet"]
        var bodyData: [String: Any] = [:]
        
        if let prdId = prdId, let prdType = prdType {
            bodyData = [
                "payment_method": paymentMethod,
                "ewallet_type_id": ewalletTypeId ?? [],
                "pay_amount": payAmount ?? [],
                "checkout": 1,
                "courier_id": courier?.courierId ?? "",
                "courier_name": courier?.company ?? "",
                "courier_service_id": courier?.serviceId ?? "",
                "delivery_fee": courier?.shipmentPrice ?? "",
                "shipping_address_id": shippingAddrId,
                "billing_address_id": billingAddrId,
                "total_amount": totalAmount ?? "",
                "voucher_code": voucherCode ?? "",
                "total_disc": totalDisc ?? "",
                "prd_id": prdId ,
                "prd_type": prdType,
                "lang_code": appData.data?.langId ?? ""
            ]
        } else {
            bodyData = [
                "payment_method": paymentMethod,
                "ewallet_type_id": ewalletTypeId ?? [],
                "pay_amount": payAmount ?? [],
                "checkout": 1,
                "courier_id": courier?.courierId ?? "",
                "courier_name": courier?.company ?? "",
                "courier_service_id": courier?.serviceId ?? "",
                "delivery_fee": courier?.shipmentPrice ?? "",
                "shipping_address_id": shippingAddrId,
                "billing_address_id": billingAddrId,
                "total_amount": totalAmount ?? "",
                "voucher_code": voucherCode ?? "",
                "total_disc": totalDisc ?? "",
                "prd_type": "",
                "lang_code": appData.data?.langId ?? ""
            ]
        }
        
        let request = apiManager.getRequest(urlPath: "api/payment-page", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: PaymentPageModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getOrderStatus(checkoutId: String? = nil, prdType: String? = nil, completion: @escaping (Bool, OrderStatusModel?) -> Void) {
        
        var bodyData: [String: Any] = [:]
        
        if let prdType = prdType {
            bodyData = [
                "checkout_id": checkoutId ?? "",
                "prd_type": prdType,
                "lang_code": appData.data?.langId ?? ""
            ]
            
        } else {
            bodyData = [
                "checkout_id": checkoutId ?? "",
                "prd_type": "",
                "lang_code": appData.data?.langId ?? ""
            ]
        }
        
        let request = apiManager.getRequest(urlPath: "api/getOrderStatus", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: OrderStatusModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func calculateShipping(completion: @escaping (Bool, CalculateShippingModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/calc-shipping", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: CalculateShippingModel.self, isShowLoading: true, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func saveGuestInfo(prdType: String? = nil,
                       name: String? = nil,
                       mobileNo: String? = nil,
                       address: String? = nil,
                       country: Int? = nil,
                       city: String? = nil,
                       state: Int? = nil,
                       zip: String? = nil,
                       email: String? = nil,
                       prefix: String? = nil,
                       completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prd_type": prdType ?? "",
            "name": name ?? "",
            "mobile_no": mobileNo ?? "",
            "address": address ?? "",
            "country_id": country ?? "",
            "city": city ?? "",
            "state_id": state ?? 0,
            "zip": zip ?? "",
            "email": email ?? "",
            "prefix_calling_code": prefix ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/save-guest", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true, arrWhiteListErrCode: [97]) { (proceed, data) in
            completion(proceed, data)
        }
    }
}
