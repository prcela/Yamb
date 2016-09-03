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

protocol GameKitHelperDelegate: class
{
    func matchStarted()
    func matchEnded()
    func matchDidReceiveData(match:GKMatch, data: NSData, fromPlayerId: String)
}

class GameKitHelper: NSObject
{
    static var shared = GameKitHelper()
    
    var authenticated = false
    var lastError: NSError?
    var authController: UIViewController?
    var currentMatch: GKTurnBasedMatch?
    weak var delegate: GameKitHelperDelegate?
    private var matchStarted = false
    
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
    
    func findMatchWithMinPlayers(minPlayers: Int, maxPlayers: Int, vc: UIViewController, delegate: GameKitHelperDelegate)
    {
        currentMatch = nil
        self.delegate = delegate
        vc.dismissViewControllerAnimated(false, completion: nil)
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        
        let mmvc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        mmvc.turnBasedMatchmakerDelegate = self
        mmvc.showExistingMatches = true
        
        vc.presentViewController(mmvc, animated: true, completion: nil)
    }
}

extension GameKitHelper: GKTurnBasedMatchmakerViewControllerDelegate
{
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController, didFindMatch match: GKTurnBasedMatch) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        print("did find match")
        currentMatch = match
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.didFindTurnBasedMatch, object: nil)
    }
    
    func turnBasedMatchmakerViewControllerWasCancelled(viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        print("Was canceled")
    }
    
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: NSError) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        print("Did fail with error: \(error.localizedDescription)")
    }
    
    func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController, playerQuitForMatch match: GKTurnBasedMatch) {
        print("player quit: \(match) \(match.currentParticipant)")
    }
}

