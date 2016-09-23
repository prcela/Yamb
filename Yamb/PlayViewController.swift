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
    @IBOutlet private weak var rollBtn: UIButton!
    @IBOutlet weak var sumLbl: UILabel!
    @IBOutlet weak var sum1Lbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var playLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(onGameStateChanged(_:)), name: NotificationName.matchStateChanged, object: nil)
        nc.addObserver(self, selector: #selector(alertForInput), name: NotificationName.alertForInput, object: nil)
        nc.addObserver(self, selector: #selector(opponentLeavedMatch(_:)), name: NotificationName.opponentLeavedMatch, object: nil)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView?.scene = DiceScene.shared
        
        sumLbl.text = nil
        sumLbl.layer.borderWidth = 1
        sumLbl.layer.borderColor = UIColor.lightGrayColor().CGColor
        sumLbl.backgroundColor = Skin.blue.labelBackColor
        
        sum1Lbl.text = nil
        sum1Lbl.layer.borderWidth = 1
        sum1Lbl.layer.borderColor = UIColor.lightGrayColor().CGColor
        sum1Lbl.backgroundColor = Skin.red.labelBackColor
        
        rollBtn.layer.borderWidth = 1
        rollBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        rollBtn.layer.cornerRadius = 5
        
        refresh()
        DiceScene.shared.recreateMaterials()
        
        let chartboostAllowed = FIRRemoteConfig.remoteConfig()["allow_chartboost"].boolValue
        let finishedOnce = NSUserDefaults.standardUserDefaults().boolForKey(Prefs.finishedOnce)
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
        sumLbl.hidden = false
        sum1Lbl.hidden = Match.shared.players.count == 1
        
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        
        let skin = (Match.shared.indexOfPlayerOnTurn == 0) ? Skin.blue : Skin.red
        
        
        let isWaitingForTurn = (Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn())
        
        rollBtn.hidden = isWaitingForTurn
        playLbl.hidden = isWaitingForTurn
        
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
            playLbl.text = lstr("1. roll")
        
        case .After1:
            if inputPos == nil || inputPos!.colIdx == TableCol.N.rawValue
            {
                playLbl.text = lstr("2. roll")
            }
            else
            {
                playLbl.text = endOfTurnText()
            }
        
        case .After2:
            if inputPos == nil || inputPos!.colIdx == TableCol.N.rawValue
            {
                playLbl.text = lstr("3. roll")
            }
            else
            {
                playLbl.text = endOfTurnText()
            }
        case .After3, .AfterN3:
            playLbl.text = endOfTurnText()
            
        case .AfterN2:
            playLbl.text = lstr("3. roll")
            
        case .WaitTurn:
            playLbl.text = lstr("1. roll")
            
        case .EndGame:
            if Match.shared.players.count > 1 && Match.shared.indexOfPlayerOnTurn == 0
            {
                playLbl.text = lstr("Next player")
            }
            else
            {
                playLbl.text = lstr("New game")
            }
        }
        
        rollBtn.enabled = Match.shared.isRollEnabled()
        nameLbl.text = player.alias
        nameLbl.textColor = skin.strokeColor
        
        let sumLbls = [sumLbl,sum1Lbl]
        
        for (idx,lbl) in sumLbls.enumerate()
        {
            if idx < Match.shared.players.count
            {
                let player = Match.shared.players[idx]
                if let score = player.table.totalScore()
                {
                    lbl.text = String(score)
                }
                else
                {
                    lbl.text = nil
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
        let alert = UIAlertController(title: "Yamb", message: lstr("Opponent has leave the match"), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
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
    }
    
    @IBAction func roll(sender: UIButton)
    {
        if Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn()
        {
            return
        }
        
        if playLbl.text == lstr("New game")
        {
            let players = Match.shared.players
            Match.shared.start(Match.shared.matchType, playersDesc: players.map({($0.id,$0.alias,$0.diceMaterial)}))
        }
        else if playLbl.text == lstr("Next player")
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
}

