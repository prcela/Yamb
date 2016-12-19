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
    @IBOutlet weak var playerBtn: UIButton?
    @IBOutlet weak var diceIcon: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(joinedMatch(_:)), name: NotificationName.joinedMatch, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationArrived(_:)), name: NotificationName.matchInvitationArrived, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationIgnored(_:)), name: NotificationName.matchInvitationIgnored, object: nil)
        nc.addObserver(self, selector: #selector(mpMatchEnded(_:)), name: NotificationName.multiplayerMatchEnded, object: nil)
        nc.addObserver(self, selector: #selector(onWsConnect), name: NotificationName.wsConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidConnect), name: NotificationName.wsDidConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidDisconnect), name: NotificationName.wsDidDisconnect, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: NotificationName.playerDiamondsChanged, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: NotificationName.playerAliasChanged, object: nil)
        nc.addObserver(self, selector: #selector(onFavDiceChanged), name: NotificationName.playerFavDiceChanged, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: NotificationName.playerStatItemsChanged, object: nil)
        
        MainViewController.shared = self

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectingLbl?.hidden = true
        connectingLbl?.text = lstr("Connecting...")
        
        diceIcon?.layer.cornerRadius = 3
        diceIcon?.clipsToBounds = true
        
        updatePlayerInfo()
    }
    
    func updatePlayerInfo()
    {
        let name = PlayerStat.shared.alias
        let diamonds = PlayerStat.shared.diamonds
        let avgScore6 = PlayerStat.avgScore(.Six)
        
        let stars = stars6(avgScore6)
        let playerTitle = String(format: "%@  💎 \(diamonds)  ⭐️ %@", name, starsFormatter.stringFromNumber(NSNumber(float: stars))!)
        playerBtn?.setTitle(playerTitle, forState: .Normal)
        diceIcon?.image = PlayerStat.shared.favDiceMat.iconForValue(1)
        
        ServerAPI.updatePlayer {_,_,_ in }
    }
    
    func onFavDiceChanged()
    {
        diceIcon?.image = PlayerStat.shared.favDiceMat.iconForValue(1)
    }

    func joinedMatch(notification: NSNotification)
    {
        let matchId = notification.object as! UInt
        if let idx = Room.main.matchesInfo.indexOf ({ (m) -> Bool in
            return m.id == matchId
        }) {
            let matchInfo = Room.main.matchesInfo[idx]
            let firstPlayerId = matchInfo.playerIds.first!
            let lastPlayerId = matchInfo.playerIds.last!
            if let firstPlayer = Room.main.player(firstPlayerId),
                let lastPlayer = Room.main.player(lastPlayerId)
            {
                Match.shared.start(.OnlineMultiplayer,
                                   diceNum: DiceNum(rawValue: matchInfo.diceNum)!,
                                   playersDesc: [
                                    (firstPlayerId,firstPlayer.alias,firstPlayer.avgScore6,DiceMaterial(rawValue: matchInfo.diceMaterials.first!)!),
                                    (lastPlayerId,lastPlayer.alias,lastPlayer.avgScore6,DiceMaterial(rawValue: matchInfo.diceMaterials.last!)!)],
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
    }
    
    func matchInvitationArrived(notification: NSNotification)
    {
        let senderPlayerId = notification.object as! String
        var matchInfo: MatchInfo?
        for mInfo in Room.main.matchesInfo
        {
            if mInfo.playerIds.first == senderPlayerId
            {
                matchInfo = mInfo
                break
            }
        }
        
        guard matchInfo != nil,
            let senderPlayer = Room.main.player(senderPlayerId) else {
                return
        }
        
        if let presentedVC = presentedViewController
        {
            if presentedVC is PlayerViewController || presentedVC is PlayViewController
            {
                presentedVC.performSegueWithIdentifier("invitation", sender: senderPlayer)
            }
        }
        else
        {
            performSegueWithIdentifier("invitation", sender: senderPlayer)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "invitation"
        {
            let invitationVC = segue.destinationViewController as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }
    }
    
    func matchInvitationIgnored(notification: NSNotification)
    {
        let recipientPlayerId = notification.object as! String
        
        guard let recipientPlayer = Room.main.player(recipientPlayerId) else {return}
        
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
        let playerId = PlayerStat.shared.id
        let playerIdx = Match.shared.players.indexOf { (p) -> Bool in
            return p.id == playerId
        }
        let player = Match.shared.players[playerIdx!]
        guard let score = player.table.totalScore() else {return}
        
        var result:Result = .Winner
        for p in Match.shared.players
        {
            p.state = .EndGame
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
        
        let statItem = StatItem(
            playerId: playerId,
            matchType: Match.shared.matchType,
            diceNum: Match.shared.diceNum,
            score: score,
            result: result,
            bet: Match.shared.bet,
            timestamp: NSDate())
        
        PlayerStat.shared.items.append(statItem)
        ServerAPI.statItem(statItem.json()) { (data, response, error) in
            print(response)
        }
        
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
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
    }
    
    func onWsConnect()
    {
        connectingLbl?.hidden = false
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
