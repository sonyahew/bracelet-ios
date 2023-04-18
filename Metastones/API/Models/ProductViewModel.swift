//
//  ProductViewModel.swift
//  Metastones
//
//  Created by Sonya Hew on 18/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class ProductViewModel: ViewModelBase {
    
    func getProductCategory(categoryType: String? = nil, completion: @escaping (Bool, ProductCategoryModule?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/prd-category?lang_code=\(appData.data?.langId ?? "")&category_type=\(categoryType ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: ProductCategoryModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getProductList(page: Int? = nil, sortBy: String? = nil, categoryId: String? = nil, filter: String? = nil, completion: @escaping (Bool, ProductListModule?) -> Void) {
        
        let bodyData: [String: Any] = [
            "page": page ?? 1,
            "item_per_page": 10,
            "sort_by": sortBy ?? "",
            "prd_category_id": categoryId ?? "",
            "lang_code": appData.data?.langId ?? "",
            "filter": filter ?? ""
        ]
        
        let request = apiManager.getRequest(urlPath: "api/product-list", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: ProductListModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getProductDetails(productId: Int, completion: @escaping (Bool, ProductDetailsModule?) -> Void) {
        
        let bodyData: [String: Any] = [
            "prd_id": productId,
            "lang_code": appData.data?.langId ?? "",
        ]
        
        let request = apiManager.getRequest(urlPath: "api/product-detail", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: ProductDetailsModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getPrice(productId: Int, optionId: String, qty: Int, completion: @escaping (Bool, PriceModule?) -> Void) {
                
        let bodyData: [String: Any] = [
            "prd_id": productId,
            "option_id": optionId,
            "qty": qty,
            "lang_code": appData.data?.langId ?? ""
        ]
        
        let request = apiManager.getRequest(urlPath: "api/get-price", bodyData: bodyData)
        apiManager.retrieveServerData(request: request, responseClass: PriceModule.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
    
    func getProductFilters(completion: @escaping (Bool, PrdFilterModel?) -> Void) {
        
        let request = apiManager.getRequest(urlPath: "api/prd-filter?lang_code=\(appData.data?.langId ?? "")", method: "GET")
        apiManager.retrieveServerData(request: request, responseClass: PrdFilterModel.self, isShowError: true) { (proceed, data) in
            completion(proceed, data)
        }
    }
}
