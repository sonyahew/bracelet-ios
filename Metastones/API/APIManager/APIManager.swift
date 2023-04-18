//
//  APIManager.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//
import UIKit
import SystemConfiguration
import HandyJSON

class APIManager {
    
    private let defaultSession = URLSession.shared
    private let popupManager = PopupManager.shared
    private let appData = AppData.shared
    private var baseURL: String
    private var urlEnv: String
    
    //private var xAuth: String
    private var arrSuccessAPICode = [200]
    private var arrKickOutAPICode = [401]
    private var arrCustomErrorAPICode = [400]
    
    private var urlRequest : URLRequest? = nil
    private var needShowError : Bool = true
    private var needShowLoading : Bool = true
    private var needRetryAPI : Bool = false
    
    var arrWhiteListAPICode : [Int] = []
    
    init() {
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: configPath),
            let backendURL = config["baseURL"] as? String,
            let urlEnvironment = config["env"] as? String
            //let xAuthorization = config["xAuth"] as? String
        {
            baseURL = backendURL
            urlEnv = urlEnvironment
            //xAuth = xAuthorization
        } else {
            baseURL = ""
            urlEnv = ""
            //xAuth = ""
        }
    }
    
    func retrieveServerData<T: HandyJSON>(request: URLRequest, responseClass: T.Type, isShowLoading: Bool? = true, isShowError: Bool? = true, needRetry: Bool? = false, arrWhiteListErrCode : [Int?] = [], completion: @escaping (Bool, T?) -> Void) {
        
        urlRequest = request
        needShowError = isShowError!
        needShowLoading = isShowLoading!
        needRetryAPI = needRetry!
        
        apiShowLoading()
        if !isConnectedToNetwork() {
            apiStopLoading()
            showErrorPopup(msg: kLb.no_internet_connection.localized, responseClass: responseClass, completion: completion)
        } else {
            
            if self.urlEnv == "DEV" {
                print("API Start \(String(describing: request.url))")
            }
            
            defaultSession.dataTask(with: request) { (data, response, error) in
                self.apiStopLoading()
                if let httpResponse = response as? HTTPURLResponse {
                    let httpStatusCode = httpResponse.statusCode
                    
                    DispatchQueue.main.async {
                        if let jsonData = data {
                            do {
                                let jsonString = String(data: jsonData, encoding: .utf8)!
                                
                                let responseData = T.self.deserialize(from: jsonString)
                                let response = APIBaseModel.self.deserialize(from: jsonString)
                                
                                if self.urlEnv == "DEV" {
                                    print("--> \(String(describing: request.url))")
                                    print(jsonString)
                                    print("<-- \(String(describing: request.url))")
                                }
                                
                                if self.arrSuccessAPICode.contains(httpStatusCode) {
                                    //HTTP Success
                                    if arrWhiteListErrCode.contains(response?.err) {
                                        completion(false, responseData)
                                        return
                                    }
                                    if let statusCode = response?.err {
                                        switch statusCode {
                                        case 0:
                                            //API Success
                                            completion(true, responseData)
                                        case 2:
                                            //API Kick Out
                                            self.popupManager.showAlert(destVC: self.popupManager.getAlertPopup(title: response?.msg == nil ? kLb.something_went_wrong_please_try_again.localized : response?.msg?.localized), completion: { (btnTitle) in
                                                self.kickOut()
                                            })
                                            completion(false, nil)
                                        case 99:
                                            self.popupManager.showAlert(destVC: self.popupManager.getComingSoonPopup(desc: response?.msg?.localized), completion: { (btnTitle) in
                                                completion(false, responseData)
                                            })
                                        default:
                                            //API Error
                                            self.showErrorPopup(msg: response?.msg?.localized, responseClass: responseClass, response: responseData, completion: completion)
                                        }
                                    } else {
                                        self.showErrorPopup(msg: response?.msg?.localized, responseClass: responseClass, completion: completion)
                                    }
                                    
                                } else if self.arrKickOutAPICode.contains(httpStatusCode) {
                                    //HTTP Kick Out
                                    self.popupManager.showAlert(destVC: self.popupManager.getAlertPopup(title: response?.msg == nil ? kLb.something_went_wrong_please_try_again.localized : response?.msg?.localized), completion: { (btnTitle) in
                                        self.kickOut()
                                    })
                                    completion(false, nil)
                                    
                                } else if self.arrCustomErrorAPICode.contains(httpStatusCode) {
                                    //HTTP Error with API Error Msg
                                    self.showErrorPopup(msg: response?.msg?.localized, responseClass: responseClass, response: responseData, completion: completion)
                                    
                                } else if self.arrWhiteListAPICode.contains(httpStatusCode) {
                                    //White List Handled API Code
                                    completion(true, nil)
                                    
                                } else {
                                    //HTTP Error with HTTP Error Msg
                                    self.showErrorPopup(msg: error?.localizedDescription, responseClass: responseClass, completion: completion)
                                }
                                
                            } catch let error {
                                //API Data Decode Error
                                print("error: [\(error)] \(String(describing: String(data: jsonData, encoding: .utf8)))")
                                self.showErrorPopup(msg: error.localizedDescription, responseClass: responseClass, completion: completion)
                            }
                        } else {
                            //API Data Missing Error
                            self.showErrorPopup(msg: error?.localizedDescription, responseClass: responseClass, completion: completion)
                        }
                    }
                }
            }.resume()
        }
    }
    
    func getRequest(urlPath: String, method: String = "POST", bodyData: [String: Any]? = nil, haveImage: Bool? = false, image: UIImage? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(baseURL)/\(urlPath)")!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = appData.data?.token, token != "" {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let sessionId = appData.data?.sessionId, sessionId != "" {
            request.addValue(sessionId, forHTTPHeaderField: "sessionId")
        }
        
        if let bodyData = bodyData {
            if let image = image, haveImage! {
                let boundary = generateBoundaryString()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                let imageData = image.jpegData(compressionQuality: 1)
                request.httpBody = createBodyWithParameters(parameters: bodyData, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
                
            } else {
                let jsonData = try? JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)
                request.httpBody = jsonData
            }
        }
        return request
    }
    
    //    func getHashParams(params : [String:Any]) -> [String:Any]{
    //        let sortedParamsKey = params.keys.sorted {
    //            $0.lowercased() < $1.lowercased()
    //        }
    //        var finalParams = params
    //
    //        var strToHash = ""
    //        for key in sortedParamsKey {
    //            strToHash += "\(params[key] ?? "")"
    //        }
    //
    //        strToHash += hashSecretKey
    //        finalParams["hash"] = strToHash.sha256()
    //
    //        return finalParams
    //    }
    
    func showErrorPopup<T: HandyJSON>(msg : String?, responseClass: T.Type, response: T? = nil, isCustom: Bool = false, completion: @escaping (Bool, T?) -> Void) {
        if needShowError {
            let popupToDisplay = isCustom ? popupManager.getMsgOnlyPopup(desc: msg) : popupManager.getErrorPopup(desc: msg ?? kLb.something_went_wrong_please_try_again.localized)
            popupManager.showAlert(destVC: popupToDisplay) { (btnTitle) in
                if self.needRetryAPI {
                    self.retrieveServerData(request: self.urlRequest!, responseClass: responseClass, isShowLoading: self.needShowLoading, isShowError: self.needShowError, needRetry: self.needRetryAPI, completion: completion)
                } else {
                    completion(false, response)
                }
            }
        } else {
            if self.needRetryAPI {
                self.retrieveServerData(request: self.urlRequest!, responseClass: responseClass, isShowLoading: self.needShowLoading, isShowError: self.needShowError, needRetry: self.needRetryAPI, completion: completion)
            } else {
                completion(false, response)
            }
        }
    }
    
    func apiShowLoading() {
        if needShowLoading {
            startLoading()
        }
    }
    
    func apiStopLoading() {
        if needShowLoading {
            stopLoading()
        }
    }
    
    func kickOut() {
        self.appData.removeAppData()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let rootNavController = appDelegate?.rootNavigationControlller
        
        appDelegate?.rootViewController.viewDidLoad()
        rootNavController?.popToRootViewController(animated: true)
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func createBodyWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string:"--\(boundary)\r\n")
                body.appendString(string:"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string:"\(value)\r\n")
            }
        }
        
        body.appendString(string:"--\(boundary)\r\n")
        body.appendString(string:"Content-Disposition: form-data; name=\"file\"\r\n\r\n")
        body.appendString(string:"\(filename)\r\n")
        
        body.appendString(string:"--\(boundary)\r\n")
        body.appendString(string:"Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string:"Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string:"\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
