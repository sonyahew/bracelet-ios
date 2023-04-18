//
//  AppData.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import KeychainAccess
import Codextended

private let kADServiceGroup = "msKeychain"

class AppData {
    
    static let shared = AppData()
    let defaults = UserDefaults.standard
    let keychain = Keychain(service: kADServiceGroup)
    
    var currentFbLive: FBLiveModel? = nil {
        didSet {
            addFbLiveTimer(fbLiveItem: currentFbLive, disableStartTimer: true)
        }
    }
    var timerList: [Timer] = []
    var fbLiveData: [FBLiveModel?] = [] {
        didSet {
            if fbLiveData.count > 0 {
                if timerList.count > 0 {
                    for timer in timerList {
                        timer.invalidate()
                    }
                }
                
                for item in fbLiveData {
                    addFbLiveTimer(fbLiveItem: item)
                }
            }
        }
    }
    
    var isLoggedIn: Bool {
        get{
            return data?.token != nil && data?.token != ""
        }
    }
    
    var data: AppDataModel? = AppDataModel.init() {
        didSet {
            if let encoded = try? data.encoded() {
                try? keychain.set(encoded, key: "data")
            }
        }
    }
    
    var translations: TranslationModel? = TranslationModel.init() {
        didSet {
            if let encoded = try? translations.encoded() {
                try? keychain.set(encoded, key: "translations")
            }
        }
    }
    
    var profile: ProfileDataModel? = ProfileDataModel.init() {
        didSet {
            if let encoded = try? data.encoded() {
                try? keychain.set(encoded, key: "profile")
            }
        }
    }
    
    var appSetting: AppSettingDataModel? = AppSettingDataModel.init() {
        didSet {
            if let encoded = try? data.encoded() {
                try? keychain.set(encoded, key: "appSetting")
            }
        }
    }
    
    func loadAppData() {
        if let decoded = keychain[data: "data"] {
            let data = try? decoded.decoded() as AppDataModel
            self.data = data
        }
        if let decoded = keychain[data: "translations"] {
            let data = try? decoded.decoded() as TranslationModel
            self.translations = data
        }
        if let decoded = keychain[data: "profile"] {
            let data = try? decoded.decoded() as ProfileDataModel
            self.profile = data
        }
        if let decoded = keychain[data: "appSetting"] {
            let data = try? decoded.decoded() as AppSettingDataModel
            self.appSetting = data
        }
    }
    
    func removeAppData() {
        data?.token = ""
        data?.cartItemCount = 0
        profile = ProfileDataModel.init()
    }
    
    func removeKeychainAllValues() {
        try? keychain.removeAll()
    }
    
    func addFbLiveTimer(fbLiveItem: FBLiveModel?, disableStartTimer: Bool? = false) {
        if let fbLiveItem = fbLiveItem {
            var startTimer: Timer!
            var endTimer: Timer!
            if let startDate = "\(fbLiveItem.startDate ?? "") \(fbLiveItem.startTime ?? "")".toDate(fromFormat: "dd/MM/yyyy HH:mm"), let endDate = "\(fbLiveItem.endDate ?? "") \(fbLiveItem.endTime ?? "")".toDate(fromFormat: "dd/MM/yyyy HH:mm"){
                startTimer = Timer(fireAt: startDate, interval: 0, target: self, selector: #selector(checkFbLiveStatusAPI), userInfo: nil, repeats: false)
                endTimer = Timer(fireAt: endDate, interval: 0, target: self, selector: #selector(checkFbLiveStatusAPI), userInfo: nil, repeats: false)
                
                if !(disableStartTimer ?? false) {
                    RunLoop.main.add(startTimer, forMode: .common)
                    timerList.append(startTimer)
                }
                
                RunLoop.main.add(endTimer, forMode: .common)
                timerList.append(endTimer)
            }
        }
    }
    
    @objc func checkFbLiveStatusAPI() {
        callFbLiveStatusAPI()
    }
}

