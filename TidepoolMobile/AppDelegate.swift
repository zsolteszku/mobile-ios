/*
* Copyright (c) 2015, Tidepool Project
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the associated License, which is identical to the BSD 2-Clause
* License as published by the Open Source Initiative at opensource.org.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the License for more details.
*
* You should have received a copy of the License along with this program; if
* not, you can obtain one from Tidepool Project at tidepool.org.
*/

import UIKit
import CoreData
import CocoaLumberjack
import HealthKit
import Bugsee

var fileLogger: DDFileLogger!

/// Set up health kit configuration singleton, specialized version of HealthKitConfiguration
let appHealthKitConfiguration = TidepoolMobileHealthKitConfiguration()

/// AppDelegate deals with app startup, restart, termination:
/// - Switches UI between login and event controllers.
/// - Initializes the UI appearance defaults.
/// - Initializes data model and api connector.

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // one shot, true until we go to foreground...
    fileprivate var freshLaunch = true
    // one shot, UI should put up dialog letting user know we are in test mode!
    static var testModeNotification = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let logger = BugseeLogger.sharedInstance() as? DDLogger
        DDLog.add(logger)

        /* Disable for final store build in case there are any timing differences...
        // Only enable Bugsee for TestFlight betas and debug builds, not for iTunes App Store releases (at least for now)
        let isRunningTestFlightBeta = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        if isRunningTestFlightBeta {
            Bugsee.launch(token:"d3170420-a6f0-4db3-970c-c4c571e5d31a")
        }
         */
        DDLogVerbose("trace")

        // Override point for customization after application launch.
        Styles.configureTidepoolBarColoring(on: true)
        
        // Initialize database by referencing username. This must be done before using the APIConnector!
        let name = TidepoolMobileDataController.sharedInstance.currentUserName
        if !name.isEmpty {
            NSLog("Initializing TidepoolMobileDataController, found and set user \(name)")
        }

        // Set up the API connection
        _ = APIConnector.connector().configure()
        
        NSLog("did finish launching")
        return true
        
        // Note: for non-background launches, this will continue in applicationDidBecomeActive...
    }
    
    static var testMode: Bool {
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: kTestModeSettingKey)
            UserDefaults.standard.synchronize()
            _testMode = nil
        }
        get {
            if _testMode == nil {
                _testMode = UserDefaults.standard.bool(forKey: kTestModeSettingKey)
            }
            return _testMode!
        }
    }
    static let kTestModeSettingKey = "kTestModeSettingKey"
    static var _testMode: Bool?

    func setupUIForLogin() {
        let sb = UIStoryboard(name: "Login", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.window?.rootViewController = vc
        }
    }
    
    func logout() {
        APIConnector.connector().logout() {
            self.setupUIForLogin()
        }
    }
    
    func setupUIForLoginSuccess() {
        // Upon login success, switch over to the EventView storyboard flow. This starts with a nav controller, and all other controllers are pushed/popped from that.
        let sb = UIStoryboard(name: "EventView", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.window?.rootViewController = vc
        }
    }
    
    fileprivate var deviceIsLocked = false
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        DDLogVerbose("Device unlocked!")
        deviceIsLocked = false
    }
    
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        DDLogVerbose("Device locked!")
        deviceIsLocked = true
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("performFetchWithCompletionHandler")
        
        // if device is locked, bail now because we can't read HealthKit data
        if deviceIsLocked {
            if AppDelegate.testMode {
                self.localNotifyMessage("TidepoolMobile skipping background fetch: device is locked!")
            }
            completionHandler(.failed)
            return
        }
        
        // next make sure we are logged in and have connectivity
        let api = APIConnector.connector()
        if api.sessionToken == nil {
            NSLog("No token available, user will need to log in!")
            // Use local notifications to test background activity...
            if AppDelegate.testMode {
                self.localNotifyMessage("TidepoolMobile was unable to download items from Tidepool: log in required!")
            }
            completionHandler(.failed)
            return
        }
        
        if !api.isConnectedToNetwork() {
            NSLog("No network available!")
            // Use local notifications to test background activity...
            if AppDelegate.testMode {
                self.localNotifyMessage("TidepoolMobile was unable to download items from Tidepool: no network available!")
            }
            completionHandler(.failed)
            return
        }
        // make sure HK interface is configured...
        // Note: this can kick off a lot of activity!
        // Note: configureHealthKitInterface is somewhat background-aware...
        TidepoolMobileDataController.sharedInstance.configureHealthKitInterface()
        // then call it...
        HealthKitDataPusher.sharedInstance.backgroundFetch { (fetchResult) -> Void in
            completionHandler(fetchResult)
        }
    }

    fileprivate func localNotifyMessage(_ msg: String) {
        NSLog("localNotifyMessage: \(msg)")
        let debugMsg = UILocalNotification()
        debugMsg.alertBody = msg
        UIApplication.shared.presentLocalNotificationNow(debugMsg)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("TidepoolMobile applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("TidepoolMobile applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("TidepoolMobile applicationWillEnterForeground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if !freshLaunch {
            checkConnection()
        }
    }
    
    func checkConnection() {
        NSLog("TidepoolMobile checkConnection")
        let api = APIConnector.connector()
        var doCheck = refreshTokenNextActive
        if let lastError = api.lastNetworkError {
            if lastError == 401 || lastError == 403 {
                NSLog("AppDelegate: last network error is \(lastError)")
                doCheck = true
            }
        }
        if doCheck {
             if api.isConnectedToNetwork() {
                refreshTokenNextActive = false
                api.lastNetworkError = nil
                NSLog("AppDelegate: attempting to refresh token in checkConnection")
                api.refreshToken() { succeeded -> (Void) in
                    if !succeeded {
                        NSLog("Refresh token failed, force login at this point...")
                        api.logout() {
                            self.setupUIForLogin()
                        }
                    }
                }
            }
        }
    }
    fileprivate var refreshTokenNextActive: Bool = false

    func applicationDidBecomeActive(_ application: UIApplication) {
        // When app is launched, either go to login, or if we have a valid token, go to main UI after optionally refreshing the token. 
        // Note: We attempt token refresh each time the app is launched; it might make more sense to do it periodically when app is brought to foreground, or just let the service control token timeout.
        NSLog("TidepoolMobile applicationDidBecomeActive")
        if freshLaunch {
            freshLaunch = false
            let api = APIConnector.connector()
            if api.sessionToken == nil {
                NSLog("No token available, clear any data in case user did not log out normally")
                api.logout() {
                    self.setupUIForLogin()
                }
                return
            }
            
            // TODO: only needed if we want to start working offline, but we will need to cache notes to make this usable...
//            if !api.isConnectedToNetwork() {
//                // Set to refresh next time we come to foreground...
//                NSLog("Offline, set to refresh token next time app enters foreground")
//                self.refreshTokenNextActive = true
//                self.setupUIForLoginSuccess()
//                return
//            }
            
            NSLog("AppDelegate: attempting to refresh token...")
            api.refreshToken() { succeeded -> (Void) in
                if succeeded {
                    let dataController = TidepoolMobileDataController.sharedInstance
                    dataController.checkRestoreCurrentViewedUser {
                        dataController.configureHealthKitInterface()
                        self.setupUIForLoginSuccess()
                    }
                } else {
                    NSLog("Refresh token failed, need to log in normally")
                    api.logout() {
                        self.setupUIForLogin()
                    }
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        TidepoolMobileDataController.sharedInstance.appWillTerminate()
        NSLog("TidepoolMobile applicationWillTerminate")
    }


}

