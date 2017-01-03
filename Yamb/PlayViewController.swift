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
import SwiftyJSON

class PlayViewController: UIViewController {
    
    static var isActive = false
    static var diceScene = DiceScene()
    
    @IBOutlet weak var gameTableView: GameTableView?
    @IBOutlet weak var sceneView: SCNView?
    @IBOutlet fileprivate weak var rollBtn: UIButton?
    @IBOutlet weak var sumLbl: UILabel?
    @IBOutlet weak var sum1Lbl: UILabel?
    @IBOutlet weak var nameLbl: UILabel?
    @IBOutlet weak var playLbl: UILabel?
    @IBOutlet weak var progressView: ProgressView?
    @IBOutlet weak var connectingLbl: UILabel?
    @IBOutlet var messageView: UIView?
    @IBOutlet weak var messageTextLbl: UILabel?
    @IBOutlet weak var chatBtn: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onGameStateChanged(_:)), name: .matchStateChanged, object: nil)
        nc.addObserver(self, selector: #selector(alertForInput), name: .alertForInput, object: nil)
        nc.addObserver(self, selector: #selector(opponentLeavedMatch(_:)), name: .opponentLeavedMatch, object: nil)
        nc.addObserver(self, selector: #selector(opponentStartedNewGame(_:)), name: .opponentNewGame, object: nil)
        nc.addObserver(self, selector: #selector(maybeSomeoneWillDump(_:)), name: .maybeSomeoneWillDump, object: nil)
        nc.addObserver(self, selector: #selector(someoneDumped(_:)), name: .dumped, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidConnect), name: .wsDidConnect, object: nil)
        nc.addObserver(self, selector: #selector(onWsDidDisconnect), name: .wsDidDisconnect, object: nil)
        nc.addObserver(self, selector: #selector(onPlayerTurnInMultiplayer(_:)), name: .onPlayerTurnInMultiplayer, object: nil)
        nc.addObserver(self, selector: #selector(onReceivedTextMessage(_:)), name: .matchReceivedTextMessage, object: nil)
        
        PlayViewController.isActive = true
    }
    
    deinit {
        PlayViewController.isActive = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sceneView?.scene = PlayViewController.diceScene
        
        sumLbl?.text = nil
        sumLbl?.layer.borderWidth = 1
        sumLbl?.layer.borderColor = UIColor.lightGray.cgColor
        sumLbl?.backgroundColor = Skin.blue.labelBackColor
        
        sum1Lbl?.text = nil
        sum1Lbl?.layer.borderWidth = 1
        sum1Lbl?.layer.borderColor = UIColor.lightGray.cgColor
        sum1Lbl?.backgroundColor = Skin.red.labelBackColor
        
        rollBtn?.layer.borderWidth = 1
        rollBtn?.layer.borderColor = UIColor.lightGray.cgColor
        rollBtn?.layer.cornerRadius = 5
        
        
        messageView?.layer.borderWidth = 1
        messageView?.layer.cornerRadius = 5
        
        refresh()
        PlayViewController.diceScene.recreateMaterials(Match.shared.players.first?.diceMaterial ?? .White)
        
        connectingLbl?.isHidden = true
        connectingLbl?.text = lstr("Connecting...")
        
        let chartboostAllowed = FIRRemoteConfig.remoteConfig()["allow_chartboost"].boolValue
        let finishedOnce = !PlayerStat.shared.items.isEmpty
        print("allow_chartboost: \(chartboostAllowed)")
        
        if chartboostAllowed && finishedOnce
        {
            if Match.shared.players.first?.state == .start
            {
                dispatchToMainQueue(delay: 45, closure: {[weak self] in
                    guard self != nil else {return}
                    if Chartboost.hasInterstitial(CBLocationLevelStart)
                    {
                        print("Chartboost.showInterstitial(CBLocationLevelStart)")
                        Chartboost.showInterstitial(CBLocationLevelStart)
                        FIRAnalytics.logEvent(withName: "show_interstitial", parameters: nil)
                    }
                    else
                    {
                        print("Chartboost.cacheInterstitial(CBLocationLevelStart)")
                        Chartboost.cacheInterstitial(CBLocationLevelStart)
                        FIRAnalytics.logEvent(withName: "cache_interstitial", parameters: nil)
                    }
                })
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        gameTableView?.updateFrames()
    }
    
    func onGameStateChanged(_ notification: Notification)
    {
        refresh()
    }
    
    func refresh()
    {
        gameTableView?.updateValuesAndStates()
        gameTableView?.setNeedsDisplay()
        sumLbl?.isHidden = false
        sum1Lbl?.isHidden = Match.shared.players.count == 1
        chatBtn?.isHidden = Match.shared.players.count == 1
        
        let playerOnTurn = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        
        let skin = (Match.shared.indexOfPlayerOnTurn == 0) ? Skin.blue : Skin.red
        progressView?.animShapeLayer.strokeColor = skin.strokeColor.cgColor
        
        
        let isWaitingForTurn = (Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn())
        
        rollBtn?.isHidden = isWaitingForTurn
        playLbl?.isHidden = isWaitingForTurn
        progressView?.isHidden = Match.shared.matchType != .OnlineMultiplayer
        
        let inputPos = playerOnTurn.inputPos
        
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
        
        var endOfTurn = false
        
        switch playerOnTurn.state {
        
        case .start:
            playLbl?.text = lstr("1. roll")
        
        case .after1:
            if inputPos == nil || inputPos!.colIdx == TableCol.n.rawValue
            {
                playLbl?.text = lstr("2. roll")
            }
            else
            {
                endOfTurn = true
                playLbl?.text = endOfTurnText()
            }
        
        case .after2:
            if inputPos == nil || inputPos!.colIdx == TableCol.n.rawValue
            {
                playLbl?.text = lstr("3. roll")
            }
            else
            {
                endOfTurn = true
                playLbl?.text = endOfTurnText()
            }
        case .after3, .afterN3:
            playLbl?.text = endOfTurnText()
            
        case .afterN2:
            playLbl?.text = lstr("3. roll")
            
        case .waitTurn:
            playLbl?.text = lstr("1. roll")
            
        case .endGame:
            if Match.shared.players.count > 1 && Match.shared.indexOfPlayerOnTurn == 0
            {
                playLbl?.text = lstr("Next player")
            }
            else
            {
                playLbl?.text = lstr("New game")
            }
            endOfTurn = true
        }
        
        // ako su sve kockice odabrane nije dozvoljen roll ali je dozvoljen "next player"
        rollBtn?.isEnabled = Match.shared.isRollEnabled() || endOfTurn
        if let alias = playerOnTurn.alias
        {
            let starsFormatted = starsFormatter.string(from: NSNumber(value: stars6(playerOnTurn.avgScore6) as Float))!
            nameLbl?.text = String(format: "%@ ⭐️ %@", starsFormatted, alias)
        }
        else
        {
            nameLbl?.text = nil
        }
        nameLbl?.textColor = skin.strokeColor
        
        let sumLbls = [sumLbl,sum1Lbl]
        
        for (idx,lbl) in sumLbls.enumerated()
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
        let alert = UIAlertController(title: "Yamb", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lstr("Confirm"), style: .default, handler: { (action) in
            print("Confirmed")
            player.confirmInputPos()
        }))
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: { (action) in
            print("Canceled")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func opponentLeavedMatch(_ notification: Notification)
    {
        
        let matchId = notification.object as! UInt
        guard matchId == Match.shared.id else {
            return
        }
        WsAPI.shared.leaveMatch(matchId)
        
        alertOnOpponentLeave()
    }
    
    
    
    func opponentStartedNewGame(_ notification: Notification)
    {
        let matchId = notification.object as! UInt
        if let match = Room.main.matchInfo(matchId)
        {
            let alert = UIAlertController(title: "Yamb", message: lstr("Opponent invites you to reply the game"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
                let desc = match.playerIds.map({ (playerId) -> (id: String?, alias: String?, avgScore6:Float, diceMat: DiceMaterial) in
                    let player = Room.main.player(playerId)!
                    return (id: player.id, alias: player.alias, avgScore6: player.avgScore6, diceMat: player.diceMaterial)
                })
                Match.shared.start(.OnlineMultiplayer, diceNum: DiceNum(rawValue: match.diceNum)!, playersDesc: desc, matchId: matchId, bet: match.bet)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action) in
                WsAPI.shared.leaveMatch(matchId)
                self.dismiss()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func maybeSomeoneWillDump(_ notification: Notification)
    {
        guard Match.shared.matchType == .OnlineMultiplayer else {
            return
        }
        
        let dumpingPlayerId = notification.object as! String
        showPopup(dumpingPlayerId, text: lstr("has connection problems\nPlease wait few seconds..."))
    }
    
    func someoneDumped(_ notification: Notification)
    {
        guard Match.shared.matchType == .OnlineMultiplayer else {
            return
        }
        
        let dumpedPlayerId = notification.object as! String
        
        WsAPI.shared.leaveMatch(Match.shared.id)
        if PlayerStat.shared.id != dumpedPlayerId
        {
            alertOnOpponentLeave()
        }
        else
        {
            dismiss()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "waitPlayer"
        {
            let waitPlayerVC = segue.destination as! WaitPlayerViewController
            waitPlayerVC.waitPlayer = sender as! Player
            
            waitPlayerVC.timout = {[weak self] in
                WsAPI.shared.leaveMatch(Match.shared.id)
                self?.alertOnOpponentLeave()
            }
        }
        else if segue.identifier == "invitation"
        {
            let invitationVC = segue.destination as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }

    }
    
    
    func alertOnOpponentLeave()
    {
        let match = Match.shared
        var message = lstr("Opponent has left the match.")
        
        let matchJustStarted = Match.shared.players.contains { (player) -> Bool in
            return player.state == .start
        }
        
        if matchJustStarted
        {
            // return initial bet
            PlayerStat.shared.diamonds += Match.shared.bet
            
            if match.bet > 0
            {
                message += "\n"
                message += String(format: lstr("Bet of %d diamonds is returned to you"), match.bet)
            }
        }
        else
        {
            PlayerStat.shared.diamonds += 2*Match.shared.bet
            
            if match.bet > 0
            {
                message += "\n"
                message += String(format: lstr("You win n diamonds"), match.bet*2)
            }
        }
        
        let alert = UIAlertController(title: "Yamb", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lstr("Continue alone"), style: .default, handler: { (action) in
            let playerId = PlayerStat.shared.id
            
            if let idx = match.players.index(where: { (player) -> Bool in
                return player.id == playerId
            }), match.players.count == 2 {
                match.players.remove(at: (idx+1)%2)
                match.indexOfPlayerOnTurn = 0
                match.matchType = .SinglePlayer
                
                let player = match.players[match.indexOfPlayerOnTurn]
                if let values = player.diceValues
                {
                    PlayViewController.diceScene.updateDiceValues(values)
                }
                PlayViewController.diceScene.updateDiceSelection(player.diceHeld)
                NotificationCenter.default.post(name: .matchStateChanged, object: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: lstr("Leave match"), style: .destructive, handler: { (action) in
            self.dismiss()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: AnyObject)
    {
        if Match.shared.matchType == .OnlineMultiplayer
        {
            let matchJustStartedOrEnded = Match.shared.players.contains { (player) -> Bool in
                return player.state == .start || player.state == .endGame
            }
            
            if matchJustStartedOrEnded
            {
                // leave without alert
                WsAPI.shared.leaveMatch(Match.shared.id)
                dismiss()
            }
            else
            {
                let alert = UIAlertController(title: "Yamb", message: lstr("Do you want to leave current match?"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: lstr("Leave match"), style: .destructive, handler: { (action) in
                    
                    WsAPI.shared.leaveMatch(Match.shared.id)
                    self.dismiss()
                }))
                alert.addAction(UIAlertAction(title: lstr("Continue match"), style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            dismiss()
        }
    }
    
    func dismiss()
    {
        self.dismiss(animated: true, completion: nil)
        
        let match = Match.shared
        if match.matchType == .SinglePlayer
        {
            NotificationCenter.default.post(name: .goToMainMenu, object: nil)
            if let player = match.players.first
            {
                if player.state != .start && player.state != .endGame
                {
                    GameFileManager.saveMatch(match)
                }
            }
        }
        else
        {
            NotificationCenter.default.post(name: .goToMainRoom, object: nil)
        }
    }
    
    @IBAction func roll(_ sender: UIButton)
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
                WsAPI.shared.turn(.newGame, matchId: Match.shared.id, params: JSON([:]))
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
    
    @IBAction func onDiceTouched(_ sender: UIButton)
    {
        print("Touched: \(sender.tag)")
        if Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn()
        {
            return
        }
        Match.shared.onDieTouched(UInt(sender.tag))
    }
    
    @IBAction func talk(_ sender: AnyObject)
    {
        let customText = "..."
        
        let messages = [
            lstr("Good luck!"),
            lstr("Lucky you!"),
            lstr("Hurry up!"),
            lstr("Nice move"),
            lstr("Good game"),
            lstr("You are good"),
            lstr("Thanks"),
            lstr("Sorry, I must leave the match"),
            customText]
        
        let localPlayerId = PlayerStat.shared.id
        
        guard let recipientPlayerIdx = Match.shared.players.index(where: { (player) -> Bool in
            return player.id != localPlayerId
        }) else {return}
        
        
        
        let recipient = Match.shared.players[recipientPlayerIdx]
        let alert = UIAlertController(title: nil, message: lstr("Send message to opponent"), preferredStyle: .actionSheet)
        for msg in messages
        {
            alert.addAction(UIAlertAction(title: msg, style: .default, handler: {action in
                if msg == customText
                {
                    self.inputCustomTextForRecipient(recipient)
                }
                else
                {
                    WsAPI.shared.sendTextMessage(recipient, text: msg)
                }
                
            }))
        }
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func inputCustomTextForRecipient(_ recipient: Player)
    {
        let alert = UIAlertController(title: "Yamb", message: lstr("Send message to opponent"), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = nil
            textField.placeholder = lstr("Message")
        }
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let msg = alert.textFields?.first?.text
            {
                WsAPI.shared.sendTextMessage(recipient, text: msg)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func onWsDidConnect()
    {
        connectingLbl?.isHidden = true
    }
    
    func onWsDidDisconnect()
    {
        if Match.shared.matchType == .OnlineMultiplayer
        {
            connectingLbl?.isHidden = false
        }
    }
    
    func onPlayerTurnInMultiplayer(_ notification: Notification)
    {
        progressView?.removeAnimation()
        progressView?.animateShape(Match.shared.turnDuration)
        let turnId = notification.object as! Int
        print(Date())
        
        guard Match.shared.isLocalPlayerTurn() else {return}
        
        dispatchToMainQueue(delay: Match.shared.turnDuration) {[weak self] in
            print(Date())
            // if still on turn
            guard Match.shared.matchType == .OnlineMultiplayer && turnId == Match.shared.turnId else {return}
            
            print("uhvaćen na kraju")
            let playerId = PlayerStat.shared.id
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
    
    func onReceivedTextMessage(_ notification: Notification)
    {
        let dic = notification.object as! [String: AnyObject]
        print(notification.object!)
        
        let text = dic["text"] as! String
        let senderID = dic["sender"] as! String
        
        showPopup(senderID, text: text)
    }
    
    fileprivate func showPopup(_ senderId: String, text: String)
    {
        messageView?.removeFromSuperview()
        let frameHeight = messageView!.frame.height
        let fullWidth = view.frame.width
        let margin:CGFloat = 10
        messageView?.frame = CGRect(x: margin, y: margin, width: fullWidth-2*margin, height: -frameHeight)
        
        guard let idxSender = Match.shared.players.index(where: { (p) -> Bool in
            return p.id == senderId
        }) else {return}
        
        let sender = Match.shared.players[idxSender]
        
        let skin = idxSender == 0 ? Skin.blue : Skin.red
        messageView?.layer.borderColor = skin.strokeColor.cgColor
        messageView?.layer.backgroundColor = skin.labelBackColor.cgColor
        messageTextLbl?.textColor = skin.strokeColor
        
        messageTextLbl?.text = "\(sender.alias!):\n\(text)"
        view.addSubview(messageView!)
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            if var frame = self?.messageView?.frame
            {
                frame.origin.y = 3*margin
                self?.messageView?.frame = frame
            }
        }) 
        
        UIView.animate(
            withDuration: 0.5, delay: 5, options: [], animations: {[weak self] in
                if var frame = self?.messageView?.frame
                {
                    frame.origin.y = -frameHeight
                    self?.messageView?.frame = frame
                }}, completion: {[weak self] finished in
                    self?.messageView?.removeFromSuperview()
        })
    }

}

