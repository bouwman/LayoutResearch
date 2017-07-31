//
//  AppDelegate.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        checkAppUpgrade()
        
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkAppUpgrade() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let versionOfLastRun = UserDefaults.standard.string(forKey: SettingsString.versionOfLastRun.rawValue)
        
        if versionOfLastRun == nil {
            // First start after installing the app
        } else if versionOfLastRun != currentVersion {
            // App was updated since last run
            // Reset settings
            let participantOptional = UserDefaults.standard.string(forKey: SettingsString.participantIdentifier.rawValue)
            let settings: StudySettings
            if let participant = participantOptional {
                settings = StudySettings.defaultSettingsForParticipant(participant)
            } else {
                settings = StudySettings.defaultSettingsForParticipant(UUID().uuidString)
            }
            settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
            
            // TODO: Remove from release
            UserDefaults.standard.removeObject(forKey: SettingsString.isParticipating.rawValue)
        } else {
            // nothing changed
            
        }
        
        UserDefaults.standard.set(currentVersion, forKey: SettingsString.versionOfLastRun.rawValue)
        UserDefaults.standard.synchronize()
    }
}

