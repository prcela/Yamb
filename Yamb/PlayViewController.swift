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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGameStateChanged(_:)), name: NotificationName.gameStateChanged, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.scene = DiceScene.shared
        refresh()
        
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
        
        switch Game.shared.state {
        case .Start:
            rollBtn.setTitle("Start", forState: .Normal)
        case .After1:
            rollBtn.setTitle("2.Roll", forState: .Normal)
        case .After2, .AfterN2:
            rollBtn.setTitle("3.Roll", forState: .Normal)
        case .After3, .AfterN3:
            rollBtn.setTitle("1.Roll", forState: .Normal)
        }
        
        rollBtn.enabled = (Game.shared.inputState != .Must || Game.shared.inputPos != nil) && Game.shared.rollState == .NotRolling
    }
    
    @IBAction func back(sender: AnyObject)
    {
        // test for score submit
        if GameKitHelper.shared.authenticated
        {
            let score = GKScore(leaderboardIdentifier: Game.shared.diceNum == .Five ? LeaderboardId.dice5 : LeaderboardId.dice6)
            score.value = Int64(Game.shared.totalScore())
            
            GKScore.reportScores([score]) { (error) in
                if error == nil
                {
                    print("score reported")
                }
            }
        }
        
        
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

