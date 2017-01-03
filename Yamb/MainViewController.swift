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
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(joinedMatch(_:)), name: .joinedMatch, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationArrived(_:)), name: .matchInvitationArrived, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationIgnored(_:)), name: .matchInvitationIgnored, object: nil)
        nc.addObserver(self, selector: #selector(mpMatchEnded(_:)), name: .multiplayerMatchEnded, object: nil)
        nc.addObserver(self, selector: #selector(onWsConnect), name: .wsConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidConnect), name: .wsDidConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidDisconnect), name: .wsDidDisconnect, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: .playerDiamondsChanged, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: .playerAliasChanged, object: nil)
        nc.addObserver(self, selector: #selector(onFavDiceChanged), name: .playerFavDiceChanged, object: nil)
        nc.addObserver(self, selector: #selector(updatePlayerInfo), name: .playerStatItemsChanged, object: nil)
        nc.addObserver(self, selector: #selector(appDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
        MainViewController.shared = self

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectingLbl?.isHidden = true
        connectingLbl?.text = lstr("Connecting...")
        
        diceIcon?.layer.cornerRadius = 3
        diceIcon?.clipsToBounds = true
        
        updatePlayerInfo()
        
    }
    
    func appDidBecomeActive()
    {
        if isViewLoaded
        {
            dispatchToMainQueue(delay: 1, closure: evaluateRetention)
        }
    }
    
    func evaluateRetention()
    {
        let calendar = Calendar.current
        let dateNow = Date()
        let dayNow = (calendar as NSCalendar).ordinality(of: .day, in: .era, for: dateNow)
        
//        PlayerStat.shared.retentions = [736330] // test
        
        if let lastRetention = PlayerStat.shared.retentions.last
        {
            if dayNow == lastRetention
            {
                // ignore it
            }
            else if dayNow == lastRetention + 1
            {
                // reward and add date to progress
                print("reward")
                PlayerStat.shared.retentions.append(dayNow)
                self.performSegue(withIdentifier: "retention", sender: self)
            }
            else
            {
                // remove complete progress, leave only current day
                PlayerStat.shared.retentions = [dayNow]
            }
        }
        else
        {
            // remove complete progress, leave only current day
            PlayerStat.shared.retentions = [dayNow]
        }
    }
    
    func updatePlayerInfo()
    {
        let name = PlayerStat.shared.alias
        let diamonds = PlayerStat.shared.diamonds
        let avgScore6 = PlayerStat.avgScore(.six)
        
        let stars = stars6(avgScore6)
        let playerTitle = String(format: "%@  💎 \(diamonds)  ⭐️ %@", name, starsFormatter.string(from: NSNumber(value: stars as Float))!)
        playerBtn?.setTitle(playerTitle, for: UIControlState())
        diceIcon?.image = PlayerStat.shared.favDiceMat.iconForValue(1)
        
        ServerAPI.updatePlayer {_,_,_ in }
    }
    
    func onFavDiceChanged()
    {
        diceIcon?.image = PlayerStat.shared.favDiceMat.iconForValue(1)
    }

    func joinedMatch(_ notification: Notification)
    {
        let matchId = notification.object as! UInt
        if let idx = Room.main.matchesInfo.index (where: { (m) -> Bool in
            return m.id == matchId
        }) {
            let matchInfo = Room.main.matchesInfo[idx]
            let firstPlayerId = matchInfo.playerIds.first!
            let lastPlayerId = matchInfo.playerIds.last!
            if let firstPlayer = Room.main.player(firstPlayerId),
                let lastPlayer = Room.main.player(lastPlayerId)
            {
                let firstDiceMat = DiceMaterial(rawValue: matchInfo.diceMaterials.first!) ?? .White
                let lastDiceMat = DiceMaterial(rawValue: matchInfo.diceMaterials.last!) ?? .White
                
                Match.shared.start(.OnlineMultiplayer,
                                   diceNum: DiceNum(rawValue: matchInfo.diceNum)!,
                                   playersDesc: [
                                    (firstPlayerId,firstPlayer.alias,firstPlayer.avgScore6,firstDiceMat),
                                    (lastPlayerId,lastPlayer.alias,lastPlayer.avgScore6,lastDiceMat)],
                                   matchId: matchId,
                                   bet: matchInfo.bet)
            
                // decrease coins for bet
            
                var diamonds = PlayerStat.shared.diamonds
                diamonds = max(0, diamonds - matchInfo.bet)
                PlayerStat.shared.diamonds = diamonds
            
                updatePlayerInfo()
            
                performSegue(withIdentifier: "playIdentifier", sender: nil)
            }
        }
    }
    
    func matchInvitationArrived(_ notification: Notification)
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
                presentedVC.performSegue(withIdentifier: "invitation", sender: senderPlayer)
            }
        }
        else
        {
            performSegue(withIdentifier: "invitation", sender: senderPlayer)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "invitation"
        {
            let invitationVC = segue.destination as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }
    }
    
    func matchInvitationIgnored(_ notification: Notification)
    {
        let recipientPlayerId = notification.object as! String
        
        guard let recipientPlayer = Room.main.player(recipientPlayerId) else {return}
        
        let alert = UIAlertController(title: "Yamb",
                                      message: String(format: lstr("Invitation ignored"), recipientPlayer.alias!),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let presentedVC = presentedViewController
        {
            presentedVC.present(alert, animated: true, completion: nil)
        }
        else
        {
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func mpMatchEnded(_ notification: Notification)
    {
        guard (notification.object as? UInt) == Match.shared.id  else {
            return
        }
        let playerId = PlayerStat.shared.id
        let playerIdx = Match.shared.players.index { (p) -> Bool in
            return p.id == playerId
        }
        let player = Match.shared.players[playerIdx!]
        guard let score = player.table.totalScore() else {return}
        
        var result:Result = .winner
        for p in Match.shared.players
        {
            p.state = .endGame
            if p.id != playerId
            {
                if let pScore = p.table.totalScore()
                {
                    if pScore > score
                    {
                        result = .loser
                    }
                    else if pScore == score
                    {
                        result = .drawn
                    }
                }
            }
        }
        
        var diamonds = PlayerStat.shared.diamonds
        
        var message: String
        switch result {
            
        case .winner:
            message = String(format: lstr("You win n diamonds"), Match.shared.bet*2)
            diamonds += Match.shared.bet*2
            
            
        case .drawn:
            message = lstr("Drawn")
            diamonds += Match.shared.bet
            
        case .loser:
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
            timestamp: Date())
        
        PlayerStat.shared.items.append(statItem)
        ServerAPI.statItem(statItem.json()) { (data, response, error) in
            print(response ?? "invalid response")
        }
        
        let alert = UIAlertController(title: lstr("Match over"),
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let presentedVC = presentedViewController
        {
            presentedVC.present(alert, animated: true, completion: nil)
        }
        else
        {
            present(alert, animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: .matchStateChanged, object: nil)
    }
    
    func onWsConnect()
    {
        connectingLbl?.isHidden = false
    }
        
    func onWsDidConnect()
    {
        connectingLbl?.isHidden = true
    }
    
    func onWsDidDisconnect()
    {
        connectingLbl?.isHidden = false
    }

}
