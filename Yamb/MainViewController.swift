//
//  MainViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 28/10/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    static var shared: MainViewController?
    
    @IBOutlet weak var connectingLbl: UILabel?
    @IBOutlet weak var playerBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(joinedMatch(_:)), name: NotificationName.joinedMatch, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationArrived(_:)), name: NotificationName.matchInvitationArrived, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationIgnored(_:)), name: NotificationName.matchInvitationIgnored, object: nil)
        nc.addObserver(self, selector: #selector(mpMatchEnded(_:)), name: NotificationName.multiplayerMatchEnded, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidConnect), name: NotificationName.wsDidConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidDisconnect), name: NotificationName.wsDidDisconnect, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: NotificationName.playerDiamondsChanged, object: nil)
        
        MainViewController.shared = self

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectingLbl?.hidden = true
        connectingLbl?.text = lstr("Connecting...")
        
        updatePlayerInfo()
    }
    
    func updatePlayerInfo()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey(Prefs.playerAlias)!
        let diamonds = PlayerStat.shared.diamonds
        let avgScore6 = PlayerStat.avgScore(.Six)
        
        let stars = stars6(avgScore6)
        let playerTitle = String(format: "\(name)  💎 \(diamonds)  ⭐️ %.1g", stars)
        playerBtn.setTitle(playerTitle, forState: .Normal)
        
        
        WsAPI.shared.updatePlayer()
    }

    func joinedMatch(notification: NSNotification)
    {
        let matchId = notification.object as! UInt
        if let idx = Room.main.matchesInfo.indexOf ({ (m) -> Bool in
            return m.id == matchId
        }) {
            let matchInfo = Room.main.matchesInfo[idx]
            let firstPlayer = matchInfo.players.first!
            let lastPlayer = matchInfo.players.last!
            Match.shared.start(.OnlineMultiplayer,
                               diceNum: DiceNum(rawValue: matchInfo.diceNum)!,
                               playersDesc: [
                                (firstPlayer.id,firstPlayer.alias,firstPlayer.avgScore6,DiceMaterial(rawValue: matchInfo.diceMaterials.first!)!),
                                (lastPlayer.id,lastPlayer.alias,lastPlayer.avgScore6,DiceMaterial(rawValue: matchInfo.diceMaterials.last!)!)],
                               matchId: matchId,
                               bet: matchInfo.bet)
            
            // decrease coins for bet
            
            var diamonds = PlayerStat.shared.diamonds
            diamonds = max(0, diamonds - matchInfo.bet)
            PlayerStat.shared.diamonds = diamonds
            
            updatePlayerInfo()
            
            performSegueWithIdentifier("playIdentifier", sender: nil)
        }
    }
    
    func matchInvitationArrived(notification: NSNotification)
    {
        let senderPlayerId = notification.object as! String
        var matchInfo: MatchInfo?
        for mInfo in Room.main.matchesInfo
        {
            if mInfo.players.first?.id == senderPlayerId
            {
                matchInfo = mInfo
                break
            }
        }
        
        guard matchInfo != nil,
            let senderPlayer = matchInfo!.players.first else {
                return
        }
        
        
        var message = String(format: lstr("Invitation message"), senderPlayer.alias!, matchInfo!.diceNum)
        
        if let bet = matchInfo?.bet where bet > 0
        {
            message += "\n"
            message += String(format: lstr("Bet is n"), bet)
        }
        
        var shouldSaveSP = false
        if Match.shared.matchType == MatchType.SinglePlayer
        {
            let spMatch = Match.shared
            if let player = spMatch.players.first
            {
                if player.state != .Start && player.state != .EndGame
                {
                    shouldSaveSP = true
                    message += lstr("SP progress will be saved")
                }
            }
        }
        
        let alert = UIAlertController(title: "Yamb",
                                      message: message,
                                      preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: lstr("Ignore"), style: .Default, handler: { (action) in
            WsAPI.shared.ignoreInvitation(senderPlayerId)
        }))
        
        alert.addAction(UIAlertAction(title: lstr("Accept"), style: .Default, handler: { (action) in
            print("prihat igre...")
            dispatch_async(dispatch_get_main_queue(), {
                if self.navigationController?.presentedViewController != nil
                {
                    if shouldSaveSP
                    {
                        GameFileManager.saveMatch(Match.shared)
                    }
                    
                    self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
                }
                self.navigationController?.popToRootViewControllerAnimated(false)
                WsAPI.shared.joinToMatch(matchInfo!.id)
            })
        }))
        
        
        
        if let presentedVC = presentedViewController
        {
            if !(presentedVC is UIAlertController)
            {
                presentedVC.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else
        {
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func matchInvitationIgnored(notification: NSNotification)
    {
        let recipientPlayerId = notification.object as! String
        
        guard let idx = Room.main.freePlayers.indexOf({ (player) in
            return player.id == recipientPlayerId
        }) else {
            return
        }
        
        let recipientPlayer = Room.main.freePlayers[idx]
        
        let alert = UIAlertController(title: "Yamb",
                                      message: String(format: lstr("Invitation ignored"), recipientPlayer.alias!),
                                      preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        if let presentedVC = presentedViewController
        {
            presentedVC.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func mpMatchEnded(notification: NSNotification)
    {
        guard (notification.object as? UInt) == Match.shared.id  else {
            return
        }
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)
        let playerIdx = Match.shared.players.indexOf { (p) -> Bool in
            return p.id == playerId
        }
        let player = Match.shared.players[playerIdx!]
        guard let score = player.table.totalScore() else {return}
        
        var result:Result = .Winner
        for p in Match.shared.players
        {
            if p.id != playerId
            {
                if let pScore = p.table.totalScore()
                {
                    if pScore > score
                    {
                        result = .Loser
                    }
                    else if pScore == score
                    {
                        result = .Drawn
                    }
                }
            }
        }
        
        var diamonds = PlayerStat.shared.diamonds
        
        var message: String
        switch result {
            
        case .Winner:
            message = String(format: lstr("You win n diamonds"), Match.shared.bet*2)
            message += "\n\n"
            message += lstr("Extra reward")
            diamonds += Match.shared.bet*2
            
            
        case .Drawn:
            message = lstr("Drawn")
            diamonds += Match.shared.bet
            
        case .Loser:
            message = lstr("You lose")
        }
        
        PlayerStat.shared.diamonds = diamonds
        
        PlayerStat.shared.items.append(StatItem(
            matchType: Match.shared.matchType,
            diceNum: Match.shared.diceNum,
            score: score,
            result: result,
            bet: Match.shared.bet,
            timestamp: NSDate()))
        
        let alert = UIAlertController(title: lstr("Match over"),
                                      message: message,
                                      preferredStyle: .Alert)
        
        if result == .Winner
        {
            alert.addAction(UIAlertAction(title: lstr("No"), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: lstr("Yes"), style: .Default, handler: { (action) in
                Chartboost.showRewardedVideo(CBLocationGameOver)
            }))
        }
        else
        {
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }
        
        if let presentedVC = presentedViewController
        {
            presentedVC.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            presentViewController(alert, animated: true, completion: nil)
        }
    }
        
    func onWsDidConnect()
    {
        connectingLbl?.hidden = true
    }
    
    func onWsDidDisconnect()
    {
        connectingLbl?.hidden = false
    }

}
