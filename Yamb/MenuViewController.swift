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
import Crashlytics

class MenuViewController: UIViewController
{
    @IBOutlet weak var trainingBtn: UIButton!
    @IBOutlet weak var mpBtn: UIButton!
    @IBOutlet weak var leaderboardBtn: UIButton!
    @IBOutlet weak var onlinePlayersLbl: UILabel!
    @IBOutlet weak var rulesBtn: UIButton!
    @IBOutlet weak var tellFriendsBtn: UIButton!
    
    var waitForLocalPlayerAuth = false
    var currentVersionMP = 6
    var minRequiredVersion = 6

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(localPlayerAuthenticated), name: NotificationName.authenticatedLocalPlayer, object: nil)
        nc.addObserver(self, selector: #selector(goToMainMenu), name: NotificationName.goToMainMenu, object: nil)
        nc.addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)

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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateOnlinePlayersCount()
    }
    
    func updateOnlinePlayersCount()
    {
        ServerAPI.info {(data, response, error) in
            if error == nil
            {
                let json = JSON(data: data!)
                let ct = json["room_main_ct"].intValue
                dispatch_async(dispatch_get_main_queue(), {
                    self.onlinePlayersLbl.hidden = (ct == 0)
                    self.onlinePlayersLbl.text = String(format: "%@: %d", lstr("Online"), ct)
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
            let alertController = UIAlertController(title: "Yamb",
                                                    message: lstr("Update message"),
                                                    preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: lstr("Cancel"), style: .Destructive, handler: { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: lstr("Update"), style: .Default, handler: { (action) in
                let url = NSURL(string: "https://itunes.apple.com/hr/app/yamb/id354188615?mt=8")!
                UIApplication.sharedApplication().openURL(url)
            }))
            presentViewController(alertController, animated: true, completion: nil)
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
        let string: String = lstr("Check out this dice game for iPhone")
        let URL: NSURL = NSURL(string: "http://apple.co/2byvskU")!
        
        let activityViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        
        Answers.logShareWithMethod(nil, contentName: "Tell friends", contentType: nil, contentId: nil, customAttributes: nil)
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
        let defaults = NSUserDefaults.standardUserDefaults()
        let leaderboardVC = GKGameCenterViewController()
        leaderboardVC.gameCenterDelegate = self
        leaderboardVC.viewState = .Leaderboards
        leaderboardVC.leaderboardIdentifier = defaults.objectForKey(Prefs.lastPlayedGameType) as? String
        
        navigationController?.presentViewController(leaderboardVC, animated: true, completion: nil)
    }
    
    @objc
    func goToMainMenu()
    {
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func onRoomInfo()
    {
        let ctConnected = Room.main.players.filter({ (p) -> Bool in
            return p.connected
        }).count
        self.onlinePlayersLbl.hidden = (ctConnected == 0)
        self.onlinePlayersLbl.text = String(format: "%@: %d", lstr("Online"), ctConnected)
    }
    
}

extension MenuViewController: GKGameCenterControllerDelegate
{
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}



