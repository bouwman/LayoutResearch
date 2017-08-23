//
//  AppDelegate.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        checkAppUpgrade()
        
        // Load remote settings if settings changed while app was terminated
        if let options: NSDictionary = launchOptions as NSDictionary? {
            let remoteNotification = options[UIApplicationLaunchOptionsKey.remoteNotification]
            if let notification = remoteNotification {
                self.application(application, didReceiveRemoteNotification: notification as! [AnyHashable : Any], fetchCompletionHandler:  { (result) in
                })
            }
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
        
        // Clear badges
        application.applicationIconBadgeNumber = 0
        
        // Reload remote settings
        reloadRemoteSettings()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Helper
    
    var activitiesViewController: ActivitiesViewController? {
        if let tabbarChilds = window?.rootViewController?.childViewControllers.first?.childViewControllers, tabbarChilds.count > 1 {
            if let activitiesVC = tabbarChilds[1].childViewControllers.first as? ActivitiesViewController {
                return activitiesVC
            }
        }
        return nil
    }
    
    func setupAppearance() {
        // White title
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    func reloadRemoteSettings() {
        if let firstActivity = activitiesViewController?.service.activities.first {
            activitiesViewController?.loadRemoteSettingsFor(activity: firstActivity, forRow: 0)
        }
    }
    
    func checkAppUpgrade() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let versionOfLastRun = UserDefaults.standard.string(forKey: SettingsString.versionOfLastRun.rawValue)
        
        if versionOfLastRun == nil {
            // First start after installing the app
        } else if versionOfLastRun != currentVersion {
            // App was updated since last run
            // Reset settings
            //            let participantOptional = UserDefaults.standard.string(forKey: SettingsString.participantIdentifier.rawValue)
            //            let settings: StudySettings
            //            if let participant = participantOptional {
            //                settings = StudySettings.defaultSettingsForParticipant(participant)
            //            } else {
            //                settings = StudySettings.defaultSettingsForParticipant(UUID().uuidString)
            //            }
            //            settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
        } else {
            // nothing changed
        }
        
        UserDefaults.standard.set(currentVersion, forKey: SettingsString.versionOfLastRun.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Notification
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        
        if let _ = notification as? CKQueryNotification {
            // Reload remote settings
            reloadRemoteSettings()
        }
    }
}

@available(iOS 10.0, *)
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let sharedInstance = NotificationHandler()
    private override init() {}
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Reset badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Show no alert when app open
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            completionHandler()
        case UNNotificationDefaultActionIdentifier: // App was opened from notification
            completionHandler()
        default:
            completionHandler()
        }
    }
}
