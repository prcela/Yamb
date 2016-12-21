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
import SwiftyStoreKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
 
        helloSwift()
        
        let prefs: [String:AnyObject] = [
            Prefs.lastPlayedGameType: LeaderboardId.dice6
        ]
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults(prefs)
                
        FIRApp.configure()
        
        
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
        
        starsFormatter.decimalSeparator = "."
        starsFormatter.maximumFractionDigits = 1
        starsFormatter.minimumFractionDigits = 0
        
        PlayerStat.loadStat()
        
        FIRAnalytics.setUserID(PlayerStat.shared.id)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let accessToken = FBSDKAccessToken.currentAccessToken(){
            print(accessToken)
        }else{
            print("Not logged In.")
        }
        
        SwiftyStoreKit.completeTransactions() { completedTransactions in
            
            for completedTransaction in completedTransactions {
                
                if completedTransaction.transactionState == .Purchased || completedTransaction.transactionState == .Restored {
                    
                    print("purchased: \(completedTransaction.productId)")
                    
                    if completedTransaction.productId == purchaseNameId
                    {
                        dispatch_async(dispatch_get_main_queue(), { 
                            PlayerStat.shared.purchasedName = true
                            PlayerStat.saveStat()
                        })
                    }
                    else if completedTransaction.productId.hasPrefix("yamb.PurchaseDice.")
                    {
                        let components = completedTransaction.productId.componentsSeparatedByString(".")
                        dispatch_async(dispatch_get_main_queue(), {
                            let diceMat = DiceMaterial(rawValue: components.last!)!
                            if !PlayerStat.shared.boughtDiceMaterials.contains(diceMat)
                            {
                                PlayerStat.shared.boughtDiceMaterials.append(diceMat)
                                PlayerStat.saveStat()
                            }
                        })
                    }
                }
            }
        }
        
        print(NSBundle.mainBundle().bundleIdentifier!)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        PlayerStat.saveStat()
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
        SwiftyStoreKit.retrieveProductsInfo(allPurchaseIds) { result in
            retrievedProducts = result.retrievedProducts
            
            if let product = result.retrievedProducts.first {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.locale = product.priceLocale
                numberFormatter.numberStyle = .CurrencyStyle
                let priceString = numberFormatter.stringFromNumber(product.price ?? 0) ?? ""
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Could not retrieve product info, Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PlayerStat.saveStat()
        
        let match = Match.shared
        if match.matchType == .SinglePlayer && PlayViewController.isActive
        {
            if let player = match.players.first
            {
                if player.state != .Start && player.state != .EndGame
                {
                    GameFileManager.saveMatch(match)
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
