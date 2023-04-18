//
//  HomeViewModel.swift
//  Metastones
//
//  Created by Sonya Hew on 11/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class HomeViewModel: ViewModelBase {
    
    func getLanding(completion: @escaping (Bool, HomeModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/home?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: HomeModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func calculateBazi(year: String? = nil, month: String? = nil, day: String? = nil, hour: String? = nil, gender: String? = nil, completion: @escaping (Bool, CalculateBzModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "year": year ?? "",
            "month": month ?? "",
            "day": day ?? "",
            "hour": hour ?? "",
            "gender": gender ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/calculate-bz", method: "POST", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: CalculateBzModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func claimRewards(rewardType: String? = nil, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "reward_type": rewardType ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/claim-reward", method: "POST", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
}




