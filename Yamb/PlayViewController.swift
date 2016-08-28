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
    @IBOutlet weak var rollBtn: UIButton!
    @IBOutlet weak var sumLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGameStateChanged(_:)), name: NotificationName.gameStateChanged, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.scene = DiceScene.shared
        refresh()
        
        sumLbl.layer.borderWidth = 1
        sumLbl.layer.borderColor = UIColor.lightGrayColor().CGColor
        
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
        
        let inputPos = Game.shared.inputPos
        
        switch Game.shared.state {
        case .Start:
            rollBtn.setTitle("1.Roll", forState: .Normal)
        case .After1:
            if inputPos == nil || inputPos!.colIdx == TableCol.N.rawValue
            {
                rollBtn.setTitle("2.Roll", forState: .Normal)
            }
            else
            {
                rollBtn.setTitle("1.Roll", forState: .Normal)
            }
        case .After2:
            if inputPos == nil || inputPos!.colIdx == TableCol.N.rawValue
            {
                rollBtn.setTitle("3.Roll", forState: .Normal)
            }
            else
            {
                rollBtn.setTitle("1.Roll", forState: .Normal)
            }
        case .After3, .AfterN3:
            rollBtn.setTitle("1.Roll", forState: .Normal)
            
        case .AfterN2:
            rollBtn.setTitle("3.Roll", forState: .Normal)
        case .End:
            rollBtn.setTitle("New game", forState: .Normal)
            sumLbl.text = String(Game.shared.table.totalScore())
            sumLbl.hidden = false
        }
        
        rollBtn.enabled = Game.shared.isRollEnabled()
        statusLbl.text = Game.shared.status()
    }
    
    @IBAction func back(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.goToMainMenu, object: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func roll(sender: AnyObject)
    {
        Game.shared.roll()
    }
    
    @IBAction func onDiceTouched(sender: UIButton)
    {
        print("Touched: \(sender.tag)")
        Game.shared.onDieTouched(UInt(sender.tag))
    }
}

