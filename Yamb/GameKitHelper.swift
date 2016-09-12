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


class GameKitHelper: NSObject
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
                
                if self.authenticated
                {
                    if let alias = localPlayer.alias
                    {
                        NSUserDefaults.standardUserDefaults().setObject(alias, forKey: Prefs.playerAlias)
                    }
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.authenticatedLocalPlayer, object: nil)
                FIRAnalytics.setUserPropertyString("gc_authenticated", forName: "gc")
            }
        }
        
    }
}


