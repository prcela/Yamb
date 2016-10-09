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
    @IBOutlet weak var mpBtn: UIButton!
    @IBOutlet weak var leaderboardBtn: UIButton!
    @IBOutlet weak var onlinePlayersLbl: UILabel!
    @IBOutlet weak var rulesBtn: UIButton!
    @IBOutlet weak var tellFriendsBtn: UIButton!
    
    var waitForLocalPlayerAuth = false
    var currentVersionMP = 1
    var minRequiredVersion = 1

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(localPlayerAuthenticated), name: NotificationName.authenticatedLocalPlayer, object: nil)
        nc.addObserver(self, selector: #selector(goToMainMenu), name: NotificationName.goToMainMenu, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // localization
        trainingBtn.setTitle(lstr("Single player"), forState: .Normal)
        mpBtn.setTitle(lstr("Multiplayer"), forState: .Normal)
        leaderboardBtn.setTitle(lstr("Leaderboard"), forState: .Normal)
        rulesBtn.setTitle(lstr("Rules"), forState: .Normal)
        tellFriendsBtn.setTitle(lstr("Tell friends"), forState: .Normal)
        
        
        // authenticate player, but dont present auth controller yet
        GameKitHelper.shared.authenticateLocalPlayer()
        
        ServerAPI.info {(data, response, error) in
            if error == nil
            {
                let json = JSON(data: data!)
                let ct = json["room_main_ct"].intValue
                dispatch_async(dispatch_get_main_queue(), { 
                    self.onlinePlayersLbl.hidden = (ct == 0)
                    self.onlinePlayersLbl.text = lstr("Online players: ") + String(ct)
                    self.minRequiredVersion = json["min_required_version"].intValue
                })
                
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.onlinePlayersLbl.hidden = true
                })
                print(error)
            }
        }
    }
    
    @IBAction func singlePlayer(sender: AnyObject)
    {
        if GameFileManager.existsSavedGame(MatchType.SinglePlayer.rawValue)
        {
            performSegueWithIdentifier("resumeOrNewId", sender: self)
        }
        else
        {
            performSegueWithIdentifier("newId", sender: self)
        }
    }
        
    @IBAction func multiPlayer(sender: AnyObject)
    {
        if currentVersionMP >= minRequiredVersion
        {
            performSegueWithIdentifier("showRoom", sender: sender)
        }
        else
        {
            performSegueWithIdentifier("mpNotAllowed", sender: sender)
        }
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
