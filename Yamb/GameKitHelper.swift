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
    var localPlayerId: String?
    
    var lastError: NSError?
    var authController: UIViewController?
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) in
            //handle authentication
            self.lastError = error as NSError?
            if let vc = viewController
            {
                self.authController = vc
            }
            else
            {
                let localPlayer = GKLocalPlayer.localPlayer()
                self.authenticated = localPlayer.isAuthenticated
                self.localPlayerId = localPlayer.playerID
                self.authController = nil
                
                NotificationCenter.default.post(name: NotificationName.authenticatedLocalPlayer, object: nil)
                FIRAnalytics.setUserPropertyString("gc_authenticated", forName: "gc")
            }
        }
        
    }
}


