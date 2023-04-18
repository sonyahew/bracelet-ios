//
//  LoginViewModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class LoginViewModel: ViewModelBase {
    
    let cartViewModel = CartViewModel()
    
    func login(prefix: String? = nil,
               mobile: String? = nil,
               password: String? = nil,
               showError: Bool? = true,
               completion: @escaping (Bool, LoginModule?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prefix_calling_code": prefix ?? "",
            "mobile_no": mobile ?? "",
            "password": password ?? "",
            "auth_type": "MOBILE_NO",
            "conn_id": 1,
            "device": UIDevice.current.name,
            "apps_version": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "",
            "os": "IOS",
            "os_version": UIDevice.current.systemVersion,
            "manufacture": "APPLE",
            "push_type": "APNS",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/login", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: LoginModule.self, isShowError: showError!) { (proceed, data) in
            if proceed {
                if let sessionId = self.appData.data?.sessionId, sessionId != "" {
                    self.appData.data?.sessionId = ""
                }
                self.appData.data?.token = data?.data?.token
                self.getProfile { (proceed, profileData) in
                    self.cartViewModel.getCart { (proceed, cartData) in
                        completion(proceed, data)
                    }
                }
                
            } else {
                completion(proceed, data)
            }
        }
    }
    
    func signup(prefix: String? = "",
                mobileNo: String? = "",
                fullName: String? = "",
                email: String? = "",
                referralCode: String? = "",
                dob: String? = "",
                gender: String? = "",
                password: String? = "",
                confirmPassword: String? = "",
                showError: Bool? = true,
                completion: @escaping (Bool, SignupModule?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prefix_calling_code": prefix ?? "",
            "mobile_no": mobileNo ?? "",
            "full_name": fullName ?? "",
            "email": email ?? "",
            "referral_code": referralCode ?? "",
            "birth_date": dob ?? "",
            "gender": gender ?? "",
            "password": password ?? "",
            "confirm_password": confirmPassword ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = self.apiManager.getRequest(urlPath: "api/signup", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: SignupModule.self, isShowError: showError) { (proceed, data) in
            if proceed {
                if let sessionId = self.appData.data?.sessionId, sessionId != "" {
                    self.appData.data?.sessionId = ""
                }
                self.appData.data?.token = data?.data?.token
                self.getProfile { (proceed, profileData) in
                    self.cartViewModel.getCart { (proceed, cartData) in
                        completion(proceed, data)
                    }
                }
                
            } else {
                completion(proceed, data)
            }
        }
    }
    
    func saveMobileInfo(needRetry: Bool? = false, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "conn_id": appData.data?.pnToken ?? "",
            "lang_code": appData.data?.langId ?? "",
            "device": UIDevice.current.name,
            "apps_version": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "",
            "os": "IOS",
            "os_version": UIDevice.current.systemVersion,
            "manufacture": "APPLE",
            "push_type": "APNS"
        ]
        let request = apiManager.getRequest(urlPath: "api/save-mobile-details", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true, needRetry: needRetry) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func otp(prefix: String? = "",
             mobileNo: String? = "",
             fullName: String? = "",
             email: String? = "",
             referralCode: String? = "",
             dob: String? = "",
             gender: String? = "",
             password: String? = "",
             confirmPassword: String? = "",
             showError: Bool? = true,
             completion: @escaping (Bool, OTPModule?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prefix_calling_code": prefix ?? "",
            "mobile_no": mobileNo ?? "",
            "full_name": fullName ?? "",
            "email": email ?? "",
            "referral_code": referralCode ?? "",
            "birth_date": dob ?? "",
            "gender": gender ?? "",
            "password": password ?? "",
            "confirm_password": confirmPassword ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = self.apiManager.getRequest(urlPath: "api/send-otp", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: OTPModule.self, isShowError: showError) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getPrefix(completion: @escaping (Bool, PrefixModule?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/prefix_calling_code?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: PrefixModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getLanguage(completion: @escaping (Bool, LanguageModule?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/language-list?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: LanguageModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func forgotPass(email: String? = "", completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "email": email ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/forgot-password", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)

        }
    }
    
    func guestSignup(password: String, cfmPassword: String, checkoutId: String, isAcademy: Bool, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "password": password,
            "confirm_password": cfmPassword,
            "checkout_id": checkoutId,
            "prd_type": isAcademy ? "Academy" : ""
        ]
        let request = apiManager.getRequest(urlPath: "api/create-password", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
}



