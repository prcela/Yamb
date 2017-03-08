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
import SwiftyJSON

class MenuViewController: UIViewController
{
    @IBOutlet weak var trainingBtn: UIButton!
    @IBOutlet weak var mpBtn: UIButton!
    @IBOutlet weak var leaderboardBtn: UIButton!
    @IBOutlet weak var onlinePlayersLbl: UILabel!
    @IBOutlet weak var rulesBtn: UIButton!
    @IBOutlet weak var tellFriendsBtn: UIButton!
    
    var waitForLocalPlayerAuth = false
    var currentVersionMP = 9
    var minRequiredVersion = 9

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(localPlayerAuthenticated), name: .authenticatedLocalPlayer, object: nil)
        nc.addObserver(self, selector: #selector(goToMainMenu), name: .goToMainMenu, object: nil)
        nc.addObserver(self, selector: #selector(onRoomInfo), name: .onRoomInfo, object: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // localization
        trainingBtn.setTitle(lstr("Single player"), for: UIControlState())
        mpBtn.setTitle(lstr("Multiplayer"), for: UIControlState())
        leaderboardBtn.setTitle(lstr("Leaderboard"), for: UIControlState())
        rulesBtn.setTitle(lstr("Rules"), for: UIControlState())
        tellFriendsBtn.setTitle(lstr("Tell friends"), for: UIControlState())
        
        
        // authenticate player, but dont present auth controller yet
        GameKitHelper.shared.authenticateLocalPlayer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                DispatchQueue.main.async(execute: {
                    self.onlinePlayersLbl.isHidden = (ct == 0)
                    self.onlinePlayersLbl.text = String(format: "%@: %d", lstr("Online"), ct)
                    self.minRequiredVersion = json["min_required_version"].intValue
                })
                
                
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    self.onlinePlayersLbl.isHidden = true
                })
                print(error!)
            }
        }
    }
    
    
    
    
    @IBAction func singlePlayer(_ sender: AnyObject)
    {
        if GameFileManager.existsSavedGame(MatchType.SinglePlayer.rawValue)
        {
            performSegue(withIdentifier: "resumeOrNewId", sender: self)
        }
        else
        {
            performSegue(withIdentifier: "newId", sender: self)
        }
    }
        
    @IBAction func multiPlayer(_ sender: AnyObject)
    {
        if currentVersionMP >= minRequiredVersion
        {
            performSegue(withIdentifier: "showRoom", sender: sender)
        }
        else
        {
            let alertController = UIAlertController(title: "Yamb",
                                                    message: lstr("Update message"),
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: lstr("Cancel"), style: .destructive, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            
            alertController.addAction(UIAlertAction(title: lstr("Update"), style: .default, handler: { (action) in
                let url = URL(string: "https://itunes.apple.com/hr/app/yamb/id354188615?mt=8")!
                UIApplication.shared.openURL(url)
            }))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onGameCenter(_ sender: AnyObject)
    {
        if let gcAuthController = GameKitHelper.shared.authController
        {
            navigationController?.present(gcAuthController, animated: true, completion: {
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
    
    
    @IBAction func tellFriends(_ sender: AnyObject)
    {
        let string: String = lstr("Check out this dice game for iPhone")
        let URL: Foundation.URL = Foundation.URL(string: "http://apple.co/2byvskU")!
        
        let activityViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
        Answers.logShare(withMethod: nil, contentName: "Tell friends", contentType: nil, contentId: nil, customAttributes: nil)
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
        let defaults = UserDefaults.standard
        let leaderboardVC = GKGameCenterViewController()
        leaderboardVC.gameCenterDelegate = self
        leaderboardVC.viewState = .leaderboards
        leaderboardVC.leaderboardIdentifier = defaults.object(forKey: Prefs.lastPlayedGameType) as? String
        
        navigationController?.present(leaderboardVC, animated: true, completion: nil)
    }
    
    @objc
    func goToMainMenu()
    {
        if let idxMenuVC = navigationController?.childViewControllers.index(where: {vc in
            return vc is MenuViewController
        }) {
            let _ = navigationController?.popToViewController(navigationController!.childViewControllers[idxMenuVC], animated: true)
        }
    }
    
    func onRoomInfo()
    {
        let ctConnected = Room.main.players.filter({ (p) -> Bool in
            return p.connected
        }).count
        self.onlinePlayersLbl.isHidden = (ctConnected == 0)
        self.onlinePlayersLbl.text = String(format: "%@: %d", lstr("Online"), ctConnected)
    }
    
}

extension MenuViewController: GKGameCenterControllerDelegate
{
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}



