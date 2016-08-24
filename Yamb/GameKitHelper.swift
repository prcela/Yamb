//
//  GameKitHelper.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit
import Firebase

class GameKitHelper
{
    static var shared = GameKitHelper()
    
    var authenticated = false
    var lastError: NSError?
    var authController: UIViewController?
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) in
            //handle authentication
            self.lastError = error
            if let vc = viewController
            {
                self.authController = vc
            }
            else
            {
                let localPlayer = GKLocalPlayer.localPlayer()
                self.authenticated = localPlayer.authenticated
                self.authController = nil
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.authenticatedLocalPlayer, object: nil)
                FIRAnalytics.setUserID(localPlayer.playerID)
                FIRAnalytics.setUserPropertyString("gc_authenticated", forName: "gc")
            }
        }
        
    }
}

struct LeaderboardId
{
    static let dice5 = "5dice.najava"
    static let dice6 = "6dice.najava"
}