//
//  PlayViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SceneKit
import GameKit
import Firebase

class PlayViewController: UIViewController {
    
    
    
    @IBOutlet weak var gameTableView: GameTableView?
    @IBOutlet weak var sceneView: SCNView?
    @IBOutlet private weak var rollBtn: UIButton?
    @IBOutlet weak var sumLbl: UILabel?
    @IBOutlet weak var sum1Lbl: UILabel?
    @IBOutlet weak var nameLbl: UILabel?
    @IBOutlet weak var playLbl: UILabel?
    @IBOutlet weak var progressView: ProgressView?
    @IBOutlet weak var connectingLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(onGameStateChanged(_:)), name: NotificationName.matchStateChanged, object: nil)
        nc.addObserver(self, selector: #selector(alertForInput), name: NotificationName.alertForInput, object: nil)
        nc.addObserver(self, selector: #selector(opponentLeavedMatch(_:)), name: NotificationName.opponentLeavedMatch, object: nil)
        nc.addObserver(self, selector: #selector(opponentStartedNewGame(_:)), name: NotificationName.opponentNewGame, object: nil)
        nc.addObserver(self, selector: #selector(someoneDisconnected(_:)), name: NotificationName.disconnected, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidConnect), name: NotificationName.wsDidConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidDisconnect), name: NotificationName.wsDidDisconnect, object: nil)
        nc.addObserver(self, selector: #selector(onPlayerTurnInMultiplayer(_:)), name: NotificationName.onPlayerTurnInMultiplayer, object: nil)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView?.scene = DiceScene.shared
        
        sumLbl?.text = nil
        sumLbl?.layer.borderWidth = 1
        sumLbl?.layer.borderColor = UIColor.lightGrayColor().CGColor
        sumLbl?.backgroundColor = Skin.blue.labelBackColor
        
        sum1Lbl?.text = nil
        sum1Lbl?.layer.borderWidth = 1
        sum1Lbl?.layer.borderColor = UIColor.lightGrayColor().CGColor
        sum1Lbl?.backgroundColor = Skin.red.labelBackColor
        
        rollBtn?.layer.borderWidth = 1
        rollBtn?.layer.borderColor = UIColor.lightGrayColor().CGColor
        rollBtn?.layer.cornerRadius = 5
        
        refresh()
        DiceScene.shared.recreateMaterials()
        
        connectingLbl?.hidden = true
        connectingLbl?.text = lstr("Connecting...")
        
        let chartboostAllowed = FIRRemoteConfig.remoteConfig()["allow_chartboost"].boolValue
        let finishedOnce = !PlayerStat.shared.items.isEmpty
        print("allow_chartboost: \(chartboostAllowed)")
        
        if chartboostAllowed && finishedOnce
        {
            if Match.shared.players.first?.state == .Start
            {
                dispatchToMainQueue(delay: 45, closure: {[weak self] in
                    guard self != nil else {return}
                    if Chartboost.hasInterstitial(CBLocationLevelStart)
                    {
                        print("Chartboost.showInterstitial(CBLocationLevelStart)")
                        Chartboost.showInterstitial(CBLocationLevelStart)
                        FIRAnalytics.logEventWithName("show_interstitial", parameters: nil)
                    }
                    else
                    {
                        print("Chartboost.cacheInterstitial(CBLocationLevelStart)")
                        Chartboost.cacheInterstitial(CBLocationLevelStart)
                        FIRAnalytics.logEventWithName("cache_interstitial", parameters: nil)
                    }
                })
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        gameTableView?.updateFrames()
    }
    
    func onGameStateChanged(notification: NSNotification)
    {
        refresh()
    }
    
    func refresh()
    {
        gameTableView?.updateValuesAndStates()
        gameTableView?.setNeedsDisplay()
        sumLbl?.hidden = false
        sum1Lbl?.hidden = Match.shared.players.count == 1
        
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        
        let skin = (Match.shared.indexOfPlayerOnTurn == 0) ? Skin.blue : Skin.red
        progressView?.animShapeLayer.strokeColor = skin.strokeColor.CGColor
        
        
        let isWaitingForTurn = (Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn())
        
        rollBtn?.hidden = isWaitingForTurn
        playLbl?.hidden = isWaitingForTurn
        progressView?.hidden = Match.shared.matchType != .OnlineMultiplayer
        
        let inputPos = player.inputPos
        
        func endOfTurnText() -> String
        {
            let gameType = Match.shared.matchType
            if gameType == .SinglePlayer
            {
                return lstr("1. roll")
            }
            else
            {
                return lstr("Next player")
            }
        }
        
        switch player.state {
        
        case .Start:
            playLbl?.text = lstr("1. roll")
        
        case .After1:
            if inputPos == nil || inputPos!.colIdx == TableCol.N.rawValue
            {
                playLbl?.text = lstr("2. roll")
            }
            else
            {
                playLbl?.text = endOfTurnText()
            }
        
        case .After2:
            if inputPos == nil || inputPos!.colIdx == TableCol.N.rawValue
            {
                playLbl?.text = lstr("3. roll")
            }
            else
            {
                playLbl?.text = endOfTurnText()
            }
        case .After3, .AfterN3:
            playLbl?.text = endOfTurnText()
            
        case .AfterN2:
            playLbl?.text = lstr("3. roll")
            
        case .WaitTurn:
            playLbl?.text = lstr("1. roll")
            
        case .EndGame:
            if Match.shared.players.count > 1 && Match.shared.indexOfPlayerOnTurn == 0
            {
                playLbl?.text = lstr("Next player")
            }
            else
            {
                playLbl?.text = lstr("New game")
            }
        }
        
        rollBtn?.enabled = Match.shared.isRollEnabled()
        if let alias = player.alias
        {
            let starsFormatted = starsFormatter.stringFromNumber(NSNumber(float:stars6(player.avgScore6)))!
            nameLbl?.text = String(format: "%@ ⭐️ %@", starsFormatted, alias)
        }
        else
        {
            nameLbl?.text = nil
        }
        nameLbl?.textColor = skin.strokeColor
        
        let sumLbls = [sumLbl,sum1Lbl]
        
        for (idx,lbl) in sumLbls.enumerate()
        {
            if idx < Match.shared.players.count
            {
                let player = Match.shared.players[idx]
                if let score = player.table.totalScore()
                {
                    lbl?.text = String(score)
                }
                else
                {
                    lbl?.text = nil
                }
            }
        }
        
    }
    
    func alertForInput()
    {
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        guard let pos = player.inputPos else {return}
        let value = player.table.values[pos.colIdx][pos.rowIdx]!
        
        let message = String(format: lstr("Confirm input"), String(value))
        let alert = UIAlertController(title: "Yamb", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: lstr("Confirm"), style: .Default, handler: { (action) in
            print("Confirmed")
            player.confirmInputPos()
        }))
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .Cancel, handler: { (action) in
            print("Canceled")
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func opponentLeavedMatch(notification: NSNotification)
    {
        
        let matchId = notification.object as! UInt
        guard matchId == Match.shared.id else {
            return
        }
        WsAPI.shared.leaveMatch(matchId)
        
        alertOnOpponentLeave()
    }
    
    
    
    func opponentStartedNewGame(notification: NSNotification)
    {
        let matchId = notification.object as! UInt
        if let match = Room.main.matchInfo(matchId)
        {
            let alert = UIAlertController(title: "Yamb", message: lstr("Opponent invites you to reply the game"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Accept", style: .Default, handler: { (action) in
                let desc = match.playerIds.map({ (playerId) -> (id: String?, alias: String?, avgScore6:Float, diceMat: DiceMaterial) in
                    let player = Room.main.player(playerId)!
                    return (id: player.id, alias: player.alias, avgScore6: player.avgScore6, diceMat: player.diceMaterial)
                })
                Match.shared.start(.OnlineMultiplayer, diceNum: DiceNum(rawValue: match.diceNum)!, playersDesc: desc, matchId: matchId, bet: match.bet)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .Destructive, handler: { (action) in
                WsAPI.shared.leaveMatch(matchId)
                self.dismiss()
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func someoneDisconnected(notification: NSNotification)
    {
        guard Match.shared.matchType == .OnlineMultiplayer else {
            return
        }
        let id = notification.object as! String
        let localPlayerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
        if let playerIdx = Match.shared.players.indexOf({ (player) -> Bool in
            return player.id == id
        }) {
            // wait player for few seconds
            let player = Match.shared.players[playerIdx]
            if player.id != localPlayerId
            {
                performSegueWithIdentifier("waitPlayer", sender: player)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "waitPlayer"
        {
            let waitPlayerVC = segue.destinationViewController as! WaitPlayerViewController
            waitPlayerVC.waitPlayer = sender as! Player
            
            waitPlayerVC.timout = {[weak self] in
                WsAPI.shared.leaveMatch(Match.shared.id)
                self?.alertOnOpponentLeave()
            }
        }
        else if segue.identifier == "invitation"
        {
            let invitationVC = segue.destinationViewController as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }

    }
    
    
    func alertOnOpponentLeave()
    {
        let match = Match.shared
        var message = lstr("Opponent has left the match.")
        
        let matchJustStarted = Match.shared.players.contains { (player) -> Bool in
            return player.state == .Start
        }
        
        if !matchJustStarted
        {
            var diamonds = PlayerStat.shared.diamonds
            diamonds += 2*Match.shared.bet
            PlayerStat.shared.diamonds = diamonds
            
            if match.bet > 0
            {
                message += "\n"
                message += String(format: lstr("You win n diamonds"), match.bet*2)
            }
        }
        
        let alert = UIAlertController(title: "Yamb", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: lstr("Continue alone"), style: .Default, handler: { (action) in
            let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
            
            if let idx = match.players.indexOf({ (player) -> Bool in
                return player.id == playerId
            }) where match.players.count == 2 {
                match.players.removeAtIndex((idx+1)%2)
                match.indexOfPlayerOnTurn = 0
                match.matchType = .SinglePlayer
                
                DiceScene.shared.updateDiceValues()
                DiceScene.shared.updateDiceSelection()
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: lstr("Leave match"), style: .Destructive, handler: { (action) in
            self.dismiss()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject)
    {
        if Match.shared.matchType == .OnlineMultiplayer
        {
            let alert = UIAlertController(title: "Yamb", message: lstr("Do you want to leave current match?"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: lstr("Leave match"), style: .Destructive, handler: { (action) in
                
                WsAPI.shared.leaveMatch(Match.shared.id)
                self.dismiss()
            }))
            alert.addAction(UIAlertAction(title: lstr("Continue match"), style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            dismiss()
        }
    }
    
    func dismiss()
    {
        dismissViewControllerAnimated(true, completion: nil)
        
        let match = Match.shared
        if match.matchType == .SinglePlayer
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.goToMainMenu, object: nil)
        
            if let player = match.players.first
            {
                if player.state != .Start && player.state != .EndGame
                {
                    GameFileManager.saveMatch(match)
                }
            }
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.goToMainRoom, object: nil)
        }
    }
    
    @IBAction func roll(sender: UIButton)
    {
        if Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn()
        {
            return
        }
        
        if playLbl!.text == lstr("New game")
        {
            let players = Match.shared.players
            Match.shared.start(Match.shared.matchType,
                               diceNum: Match.shared.diceNum,
                               playersDesc: players.map({($0.id,$0.alias,$0.avgScore6,$0.diceMaterial)}),
                               matchId: Match.shared.id,
                               bet: Match.shared.bet)
            
            if Match.shared.matchType == .OnlineMultiplayer
            {
                WsAPI.shared.turn(.NewGame, matchId: Match.shared.id, params: JSON([:]))
            }
        }
        else if playLbl!.text == lstr("Next player")
        {
            Match.shared.nextPlayer()
        }
        else
        {
            Match.shared.roll()
        }
    }
    
    @IBAction func onDiceTouched(sender: UIButton)
    {
        print("Touched: \(sender.tag)")
        if Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn()
        {
            return
        }
        Match.shared.onDieTouched(UInt(sender.tag))
    }
    
    func onWsDidConnect()
    {
        connectingLbl?.hidden = true
    }
    
    func onWsDidDisconnect()
    {
        if Match.shared.matchType == .OnlineMultiplayer
        {
            connectingLbl?.hidden = false
        }
    }
    
    func onPlayerTurnInMultiplayer(notification: NSNotification)
    {
        progressView?.removeAnimation()
        progressView?.animateShape(Match.shared.turnDuration)
        let turnId = notification.object as! Int
        print(NSDate())
        
        guard Match.shared.isLocalPlayerTurn() else {return}
        
        dispatchToMainQueue(delay: Match.shared.turnDuration) {[weak self] in
            print(NSDate())
            // if still on turn
            guard Match.shared.matchType == .OnlineMultiplayer && turnId == Match.shared.turnId else {return}
            
            print("uhvaćen na kraju")
            let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
            guard let player = Match.shared.player(playerId) else {return}
            
            if player.inputPos == nil
            {
                player.forceAnyTurn()
            }
            if player.shouldEnd()
            {
                player.end()
                
                if Match.shared.indexOfPlayerOnTurn == 0
                {
                    Match.shared.nextPlayer()
                }
                else
                {
                    self?.refresh()
                }
            }
            else
            {
                Match.shared.nextPlayer()
            }
        }
    }

}

