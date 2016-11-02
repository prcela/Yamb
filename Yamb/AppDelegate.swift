//
//  AppDelegate.swift
//  Yamb
//
//  Created by prcela on 01/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        let prefs: [String:AnyObject] = [
            Prefs.firstRun: true,
            Prefs.lastPlayedGameType: LeaderboardId.dice6
        ]
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults(prefs)
        
        if defaults.boolForKey(Prefs.firstRun)
        {
            let rndPlayerId = String(arc4random())
            let rndPlayerAlias = lstr("Player") + "_" + rndPlayerId
            defaults.setBool(false, forKey: Prefs.firstRun)
            defaults.setObject(rndPlayerId, forKey: Prefs.playerId)
            defaults.setObject(rndPlayerAlias, forKey: Prefs.playerAlias)
        }
                
        FIRApp.configure()
        FIRAnalytics.setUserID(defaults.stringForKey(Prefs.playerId)!)
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        Fabric.with([Crashlytics.self])
        
        Chartboost.startWithAppId("57b7fc8704b0163534a45ef3", appSignature: "f2baf66f467982be8bfc24bdd3b93e9ef9372714", delegate: self)
        
        let firRemoteConfig = FIRRemoteConfig.remoteConfig()
        firRemoteConfig.setDefaultsFromPlistFileName("DefaultRemoteConfig")
        
        // 1 hour
        let expirationDuration:NSTimeInterval = 3600
        
        firRemoteConfig.fetchWithExpirationDuration(expirationDuration) { (status, error) in
            if status == .Success
            {
                print("fetched FB remote config")
                firRemoteConfig.activateFetched()
            }
            
            if error != nil
            {
                print("Fetch FB config error \(error!)")
            }
        }
        
        PlayerStat.loadStat()
        
        print(NSBundle.mainBundle().bundleIdentifier!)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PlayerStat.saveStat()
    }


}


extension AppDelegate: ChartboostDelegate
{
    func didDisplayRewardedVideo(location: String!) {
        print("did display rewarded video")
    }
    
    func didCompleteRewardedVideo(location: String!, withReward reward: Int32) {
        print("did complete rewarded video with reward \(reward)")
        
        var diamonds = PlayerStat.shared.diamonds
        diamonds += Int(reward)
        PlayerStat.shared.diamonds = diamonds
    }
    
    func didFailToLoadRewardedVideo(location: String!, withError error: CBLoadError) {
        print("didFailToLoadRewardedVideo \(error.rawValue)")
    }
    
    func didDismissInterstitial(location: String!) {
        print("didDismissInterstitial")
    }
    
    func didCloseInterstitial(location: String!) {
        print("didCloseInterstitial")
    }
    
    func didFailToLoadInterstitial(location: String!, withError error: CBLoadError) {
        print("didFailToLoadInterstitial \(error.rawValue)")
    }
}
