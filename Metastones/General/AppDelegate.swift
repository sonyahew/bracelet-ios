//
//  AppDelegate.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications

let hasRunBefore = "hasRunBefore"

enum PNKey: String {
    case quote = "quote"
    case rebate = "rebate"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var rootNavigationControlller = RootNavigationController()
    var rootViewController = RootViewController()
    
    let appData = AppData.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: hasRunBefore) {
            AppData.shared.removeKeychainAllValues()
        }
        
        registerForPushNotifications(application: application)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        self.startApp()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        callFbLiveStatusAPI()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK:- Push Notification
    func registerForPushNotifications(application: UIApplication) {
        if !application.isRegisteredForRemoteNotifications {
            application.registerForRemoteNotifications()
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        appData.data?.pnToken = token
        LoginViewModel().saveMobileInfo() { (proceed, data) in }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("FailToRegisterForRemoteNotifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        appData.loadAppData()

        let aps = userInfo["aps"] as! NSDictionary

        if let customData = aps["custom_data"] as? String {
            var responseData : PNCustomDataModel?
            responseData = PNCustomDataModel.self.deserialize(from: customData)
            pnNavigation(data: responseData)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    private func startApp() {
        rootViewController = RootViewController.init(nibName: nil, bundle: nil)
        rootNavigationControlller = RootNavigationController.init(rootViewController: rootViewController)
        
        window?.rootViewController = rootNavigationControlller
        window?.makeKeyAndVisible()
    }
    
    private func pnNavigation(data: PNCustomDataModel?) {
        if let data = data, let key = data.key {
            switch key {
                case PNKey.quote.rawValue:
                    if let quoteId = data.quoteId, quoteId != "" {
                        appData.data?.quoteId = quoteId
                        let vc = getVC(sb: "Landing", vc: "AnnouncementVC") as! AnnouncementVC
                        vc.isMenu = false
                        UIApplication.topViewController()?.navigationController?.present(vc, animated: true)
                    }
                
                case PNKey.rebate.rawValue:
                    UIApplication.topViewController()?.navigationController?.pushViewController(getVC(sb: "Profile", vc: "TransactionsVC"), animated: true)
                
                default:
                    return
            }
        }
    }
}

