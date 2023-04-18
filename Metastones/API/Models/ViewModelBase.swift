//
//  ViewModelBase.swift
//  Metastones
//
//  Created by Sonya Hew on 11/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ViewModelBase {
    
    let apiManager = APIManager()
    let appData = AppData.shared
    
    func getAppVersion(completion: @escaping (Bool, AppVersionModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "platform": "ios",
            "appVers": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/app-version", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: AppVersionModel.self, isShowError: true, needRetry: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getTranslations(completion: @escaping (Bool, TranslationModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/translation", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: TranslationModel.self, isShowError: true, needRetry: true) { (proceed, data) in
            if proceed {
                self.appData.translations = data
            }
            completion(proceed, data)
        }
    }
    
    func getAppSetting(completion: @escaping (Bool, AppSettingModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/app-setting?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: AppSettingModel.self, isShowError: true, needRetry: true) { (proceed, data) in
            if proceed {
                self.appData.appSetting = data?.data
            }
            completion(proceed, data)
        }
    }
    
    func getProfile(needRetry: Bool? = false, completion: @escaping (Bool, ProfileModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/profile?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: ProfileModel.self, isShowError: true, needRetry: needRetry) { (proceed, data) in
            if proceed {
                self.appData.profile = data?.data
            }
            completion(proceed, data)
        }
    }
    
    func getWalletDetail(ewalletType: String? = nil, completion: @escaping (Bool, WalletDetailModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "ewallet_type": ewalletType ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/wallet-detail", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: WalletDetailModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getNotification(page: Int? = nil, completion: @escaping (Bool, NotificationModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "page": page ?? 1,
            "item_per_page": "10",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/notification", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: NotificationModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func updateWishlist(prdMasterId: String? = nil, isFav: Bool, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prd_master_id": prdMasterId ?? "",
            "type": isFav ? "REMOVE" : "ADD",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/add-wishlist", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getDailyQuote(id: String? = nil, completion: @escaping (Bool, DailyQuoteModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "id": id ?? "",
            "lang_code": appData.data?.langId ?? "",
        ]
        let request = apiManager.getRequest(urlPath: "api/daily-quote", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: DailyQuoteModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func sendOTP(prefix: String? = nil, mobileNo: String? = nil, completion: @escaping (Bool, MobileOTPModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prefix_no": prefix ?? "",
            "mobile_no": mobileNo ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/send-otp", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: MobileOTPModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func fbLiveStatus(completion: @escaping (Bool, FBLiveStatusModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/fb-live", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: FBLiveStatusModel.self, isShowLoading: false, isShowError: false) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getSessionId(completion: @escaping (Bool, SessionIdModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/session-id", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: SessionIdModel.self, isShowError: true, needRetry: true) { (proceed, data) in
            if proceed {
                self.appData.data?.sessionId = data?.data?.sessionId
            }
            completion(proceed, data)
        }
    }
}

