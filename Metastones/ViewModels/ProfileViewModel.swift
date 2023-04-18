//
//  ProfileViewModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 19/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ProfileViewModel: ViewModelBase {
    func updateProfile(fullName: String? = nil, dob: String? = nil, email: String? = nil, gender: String? = nil, notification: String? = nil, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "full_name": fullName ?? "",
            "birth_date": dob ?? "",
            "email": email ?? "",
            "gender": gender ?? "",
            "notification": notification ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        
        let request = apiManager.getRequest(urlPath: "api/update-profile", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            self.getProfile { (proceed, profileData) in
                if proceed {
                    completion(proceed, data)
                }
            }
        }
    }
    
    func getCountry(completion: @escaping (Bool, CityStateModule?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/country-list?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: CityStateModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getState(countryId: Int, completion: @escaping (Bool, CityStateModule?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/state-list?country_id=\(countryId)&lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: CityStateModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getCity(stateId: Int, completion: @escaping (Bool, CityStateModule?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/city-list?state_id=\(stateId)&lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: CityStateModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getWalletTrxList(ewalletType: String? = nil, page: Int? = nil, completion: @escaping (Bool, WalletTrxModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "page": page ?? 1,
            "item_per_page": 10,
            "ewallet_type": ewalletType ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/wallet-transaction-list", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: WalletTrxModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getOrderList(status: String? = nil,  itemPerPage: String? = nil, page: String? = nil, completion: @escaping (Bool, OrderHistoryModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "page": page ?? 1,
            "item_per_page": 10,
            "status": status ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/order-transaction-list", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: OrderHistoryModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }

    func getBaziList(completion: @escaping (Bool, BaziBookModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/bazi-book?lang_code=\(appData.data?.langId ?? "")")
        apiManager.retrieveServerData(request: request, responseClass: BaziBookModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func saveBazi(year: String? = nil, month: String? = nil, day: String? = nil, hour: String? = nil, gender: String? = nil, name: String? = nil, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "year": year ?? "",
            "month": month ?? "",
            "day": day ?? "",
            "hour": hour ?? "",
            "gender": gender ?? "",
            "name": name ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/save-bz", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getFriendList(completion: @escaping (Bool, FriendListModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/friend-list?lang_code=\(appData.data?.langId ?? "")")
        apiManager.retrieveServerData(request: request, responseClass: FriendListModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
        
    func updateAddress(category: String? = nil,
                       addressId: Int? = nil,
                       addrType: String? = nil,
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
            "category": category ?? "",
            "address_id": addressId ?? 0,
            "addr_type": addrType ?? "",
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
        let request = apiManager.getRequest(urlPath: "api/save-address", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            if proceed {
                self.getProfile { (proceed, data) in }
            }
            completion(proceed, data)
        }
    }
    
    func getWishlist(completion: @escaping (Bool, WishlistModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/my-wishlist?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: WishlistModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getWithdrawalPage(completion: @escaping (Bool, WithdrawalModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/withdrawal-page?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: WithdrawalModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func saveWithdrawalRequest(fullName: String? = nil,
                               prefixNo: String? = nil,
                               mobileNo: String? = nil,
                               email: String? = nil,
                               nric: String? = nil,
                               bankTypeId: String? = nil,
                               bankAccNo: String? = nil,
                               withdrawAmount: String? = nil,
                               otp: String? = nil,
                               completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "full_name": fullName ?? "",
            "prefix_no": prefixNo ?? "",
            "mobile_no": mobileNo ?? "",
            "email": email ?? "",
            "nric": nric ?? "",
            "bank_type_id": bankTypeId ?? "",
            "bank_acc_no": bankAccNo ?? "",
            "withdraw_amount": withdrawAmount ?? "",
            "otp": otp ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/save-withdrawal", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func withdrawalList(page: Int? = nil,
                        completion: @escaping (Bool, MyWithdrawalModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "page": page ?? 1,
            "item_per_page": 10,
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/withdrawal-list", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: MyWithdrawalModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func updateWithdrawal(withdrawalId: Int? = nil,
                          completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "withdrawal_id": withdrawalId ?? 0,
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/update-withdrawal", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func removeBazi(baziId: Int? = nil,
                    completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "bazi_id": baziId ?? 0,
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/remove-bazi", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
}
