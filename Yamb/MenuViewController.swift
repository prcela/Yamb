//
//  MenuViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import GameKit
import MessageUI

class MenuViewController: UIViewController
{
    @IBOutlet weak var trainingBtn: UIButton!
    @IBOutlet weak var nearbyBtn: UIButton!
    
    var waitForLocalPlayerAuth = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(localPlayerAuthenticated), name: NotificationName.authenticatedLocalPlayer, object: nil)
        
        nc.addObserver(self, selector: #selector(goToMainMenu), name: NotificationName.goToMainMenu, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // authenticate player, but dont present auth controller yet
        GameKitHelper.shared.authenticateLocalPlayer()
    }
    
    @IBAction func singlePlayer(sender: AnyObject)
    {
        if GameFileManager.existsSavedGame("singlePlayer")
        {
            performSegueWithIdentifier("resumeOrNewId", sender: self)
        }
        else
        {
            performSegueWithIdentifier("newId", sender: self)
        }
    }
        
    @IBAction func multiPlayer(sender: AnyObject) {
    }
    
    @IBAction func onGameCenter(sender: AnyObject)
    {
        if let gcAuthController = GameKitHelper.shared.authController
        {
            navigationController?.presentViewController(gcAuthController, animated: true, completion: {
            })
        }
        else if GameKitHelper.shared.authenticated
        {
            showLeaderboard()
        }
        else
        {
            waitForLocalPlayerAuth = true
        }
    }
    
    
    @IBAction func tellFriends(sender: AnyObject)
    {
        guard MFMessageComposeViewController.canSendText() else {return}
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.subject = "Yamb"
        messageVC.body = "Check out this dice game for iPhone \nhttp://apple.co/2byvskU"
        
        presentViewController(messageVC, animated: true, completion: nil)
    }
    
    @objc
    func localPlayerAuthenticated()
    {
        if waitForLocalPlayerAuth
        {
            showLeaderboard()
            waitForLocalPlayerAuth = false
        }
    }
    
    
    func showLeaderboard()
    {
        let leaderboardVC = GKGameCenterViewController()
        leaderboardVC.gameCenterDelegate = self
        leaderboardVC.viewState = .Leaderboards
        leaderboardVC.leaderboardIdentifier = LeaderboardId.dice5
        
        navigationController?.presentViewController(leaderboardVC, animated: true, completion: nil)
    }
    
    @objc
    func goToMainMenu()
    {
        navigationController?.popToRootViewControllerAnimated(false)
    }
}

extension MenuViewController: GKGameCenterControllerDelegate
{
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MenuViewController: MFMessageComposeViewControllerDelegate
{
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}