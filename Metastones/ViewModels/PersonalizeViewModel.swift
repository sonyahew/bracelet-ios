//
//  PersonalizeViewModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 06/01/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit

class PersonalizeViewModel: ViewModelBase {
    func customBraceletSetup(completion: @escaping (Bool, BraceletSetupModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/customBraceletSetup?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: BraceletSetupModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func customBraceletDetails(braceletSize: String? = nil, beadSize: String? = nil, totalBead: String? = nil, baziBalance: String? = nil, completion: @escaping (Bool, BraceletDetailsModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "bracelet_size": braceletSize ?? "",
            "bead_size": beadSize ?? "",
            "total_bead": totalBead ?? "",
            "baziBalance": baziBalance ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/customBraceletDetails", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: BraceletDetailsModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func postCustomBracelet(data: String? = nil, completion: @escaping (Bool, APIBaseModel?) -> Void) {
        
        let bodyData: [String: Any] = [
            "data": data ?? "",
            "lang_code": appData.data?.langId ?? ""
        ]
        let request = apiManager.getRequest(urlPath: "api/postBuyCustomBracelet", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: APIBaseModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
}
