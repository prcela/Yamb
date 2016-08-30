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
    
    
    
    @IBOutlet weak var gameTableView: GameTableView!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet private weak var rollBtn: UIButton!
    @IBOutlet weak var sumLbl: UILabel!
    @IBOutlet weak var sum1Lbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var playLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(onGameStateChanged(_:)), name: NotificationName.gameStateChanged, object: nil)
        nc.addObserver(self, selector: #selector(alertForInput), name: NotificationName.alertForInput, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.scene = DiceScene.shared
        refresh()
        
        sumLbl.layer.borderWidth = 1
        sumLbl.layer.borderColor = UIColor.lightGrayColor().CGColor
        sum1Lbl.backgroundColor = Skin.labelBlueBackColor
        
        sum1Lbl.layer.borderWidth = 1
        sum1Lbl.layer.borderColor = UIColor.lightGrayColor().CGColor
        sum1Lbl.backgroundColor = Skin.labelRedBackColor
        
        rollBtn.layer.borderWidth = 1
        rollBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        rollBtn.layer.cornerRadius = 5
        
        if Game.shared.state == .Start
        {
            dispatchToMainQueue(delay: 2, closure: { 
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
    
    override func viewDidLayoutSubviews()
    {
        gameTableView.updateFrames()
    }
    
    func onGameStateChanged(notification: NSNotification)
    {
        refresh()
    }
    
    func refresh()
    {
        gameTableView.updateValuesAndStates()
        gameTableView.setNeedsDisplay()
        sumLbl.hidden = true
        sum1Lbl.hidden = true
        let player = Game.shared.players[Game.shared.idxPlayer]
        
        let inputPos = Game.shared.inputPos
        
        func endOfTurnText() -> String
        {
            if Game.shared.players.count == 1
            {
                return lstr("1. roll")
            }
            else
            {
                return lstr("Next player")
            }
        }
        
        switch Game.shared.state {
        
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
            
        case .NextPlayer:
            playLbl.text = lstr("1. roll")
            
        case .End:
            if Game.shared.players.count > 1 && Game.shared.idxPlayer == 0
            {
                playLbl.text = lstr("Next player")
            }
            else
            {
                playLbl.text = lstr("New game")
            }
            
            sumLbl.hidden = false
            if Game.shared.idxPlayer == 0
            {
                sumLbl.text = String(player.table.totalScore())
            }
            else if Game.shared.idxPlayer == 1
            {
                sum1Lbl.text = String(player.table.totalScore())
                sum1Lbl.hidden = false
            }
        }
        
        rollBtn.enabled = Game.shared.isRollEnabled()
        statusLbl.text = Game.shared.status()
    }
    
    func alertForInput()
    {
        guard let pos = Game.shared.inputPos else {return}
        let player = Game.shared.players[Game.shared.idxPlayer]
        let value = player.table.values[pos.colIdx][pos.rowIdx]!
        
        let message = String(format: lstr("Confirm input"), String(value))
        let alert = UIAlertController(title: "Yamb", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: lstr("Confirm"), style: .Default, handler: { (action) in
            print("Confirmed")
            Game.shared.confirmInputPos()
        }))
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .Cancel, handler: { (action) in
            print("Canceled")
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.goToMainMenu, object: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func roll(sender: UIButton)
    {
        if playLbl.text == lstr("Next player")
        {
            Game.shared.nextPlayer()
        }
        else
        {
            Game.shared.roll()
        }
    }
    
    @IBAction func onDiceTouched(sender: UIButton)
    {
        print("Touched: \(sender.tag)")
        Game.shared.onDieTouched(UInt(sender.tag))
    }
}

