//
//  AppDelegate.swift
//  My Message
//
//  Created by Nikola Popovic on 2/17/18.
//  Copyright © 2018 Nikola Popovic. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    fileprivate var userDefaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        presentPage()
        registerForPushNotification()
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String : AnyObject]
            print(aps as NSDictionary)
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: homeVC)
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
        
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        FireBaseHelper.sharedInstance.signOut { (error) in
            if error == nil {
                print("User has sign out")
            } else {
                print("Some problem has occured \(String(describing: error))")
            }
            
        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func presentPage(){
        let emailDefaults = Defaults.getEmail()
        let passDefaults = Defaults.getPassword()
        
        
        if let email = emailDefaults, let pass = passDefaults {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: startUpVC)
            self.window?.makeKeyAndVisible()
            FireBaseHelper.sharedInstance.logIn(email: email, password: pass, CompletionHandler: { (error) in
                
                if error == nil {
                    let vc = storyBoard.instantiateViewController(withIdentifier: homeVC)
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                } else {
                    let vc = storyBoard.instantiateViewController(withIdentifier: loginVC)
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }
            })
        }
    }
}

// MARK: Push Notification
extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    func registerForPushNotification () {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Perrmision granted: \(granted)")
            
            guard granted else {
                return
            }
            self.registerNotificationSettings()
        }
    }
    
    func registerNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else {
                return
            }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

