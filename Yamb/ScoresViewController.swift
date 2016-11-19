//
//  ScoresViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 13/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import GameKit

var scoreSelekcija = ScorePickerSelekcija()

class ScoresViewController: UIViewController
{
    
    private var allPlayers: [String:PlayerInfo]?
    private var allStatItems: [StatItem]?
    private var sortedPlayers = [PlayerInfo]()
    private var filteredItems = [StatItem]()
    private var gcLeaderboard6 = GKLeaderboard()
    private var gcLeaderboard5 = GKLeaderboard()

    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var selectBtn: UIButton?
    @IBOutlet weak var pickerContainerView: UIView?
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn?.setTitle(lstr("Back"), forState: .Normal)
        selectBtn?.setTitle(scoreSelekcija.title(), forState: .Normal)
        
        // get all players
        ServerAPI.players { [weak self] (data, response, error) in
            self?.allPlayers = [String:PlayerInfo]()
            guard data != nil && error == nil
                else {return}
            
            let jsonPlayers = JSON(data: data!)
            guard !jsonPlayers.isEmpty else {return}
            for json in jsonPlayers.array!
            {
                let playerInfo = PlayerInfo(json: json)
                self?.allPlayers![playerInfo.id] = playerInfo
            }
            dispatch_async(dispatch_get_main_queue(), {
                self?.evaluateBestScores()
                self?.reload()
            })
        }
        
        // get all stats
        ServerAPI.statItems { [weak self] (data, response, error) in
            self?.allStatItems = [StatItem]()
            
            guard data != nil && error == nil
                else {return}
            
            let jsonItems = JSON(data: data!)
            guard !jsonItems.isEmpty else {return}
            for json in jsonItems.array!
            {
                self?.allStatItems?.append(StatItem(json: json))
            }
            dispatch_async(dispatch_get_main_queue(), {
                self?.evaluateBestScores()
                self?.reload()
            })
        }
        
        // get leaderboard 6 from GC
        gcLeaderboard6.timeScope = GKLeaderboardTimeScope.AllTime
        gcLeaderboard6.identifier = LeaderboardId.dice6
        gcLeaderboard6.range = NSMakeRange(1, 100)
        gcLeaderboard6.loadScoresWithCompletionHandler { [weak self] (scores, error) in
            if error != nil
            {
                print(error)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self?.reload()
                })
            }
        }
        
        // get leaderboard 5 from GC
        gcLeaderboard5.timeScope = GKLeaderboardTimeScope.AllTime
        gcLeaderboard5.identifier = LeaderboardId.dice5
        gcLeaderboard5.range = NSMakeRange(1, 100)
        gcLeaderboard5.loadScoresWithCompletionHandler { [weak self] (scores, error) in
            if error != nil
            {
                print(error)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self?.reload()
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPicker"
        {
            let scorePickerVC = segue.destinationViewController as! ScorePickerViewController
            scorePickerVC.scorePickerDelegate = self
            
        }
    }
    
    func evaluateBestScores()
    {
        guard allPlayers != nil && allStatItems != nil else {
            return
        }
        
        // reset max scores
        for (_,p) in allPlayers!
        {
            p.maxScore5 = 0
            p.maxScore6 = 0
        }
        
        let day: NSTimeInterval = 24*60*60
        for statItem in allStatItems!
        {
            let timeInterval = NSDate().timeIntervalSinceDate(statItem.timestamp)
            
            switch scoreSelekcija.timeRange
            {
            case .Week:
                if timeInterval > 7*day
                {
                    continue
                }
            
            case .Today:
                if timeInterval > day
                {
                    continue
                }
            default:
                break
            }
            
            if let playerInfo = allPlayers![statItem.playerId]
            {
                if statItem.diceNum == .Five
                {
                    if playerInfo.maxScore5 < statItem.score
                    {
                        playerInfo.maxScore5 = statItem.score
                    }
                }
                else if statItem.diceNum == .Six
                {
                    if playerInfo.maxScore6 < statItem.score
                    {
                        playerInfo.maxScore6 = statItem.score
                    }
                }
            }
        }
        sortedPlayers = allPlayers!.map({ (id, playerInfo) -> PlayerInfo in
            return playerInfo
        })
    }
    
    func reload()
    {
        sortedPlayers.sortInPlace({ (p0, p1) -> Bool in
            switch scoreSelekcija.scoreType
            {
            case .FiveDice:
                switch scoreSelekcija.scoreValue
                {
                case .Score:
                    return p0.maxScore5 > p1.maxScore5
                case .Stars:
                    return p0.avgScore5 > p1.avgScore5
                default:
                    return false
                }
                
            case .SixDice:
                switch scoreSelekcija.scoreValue
                {
                case .Score:
                    return p0.maxScore6 > p1.maxScore6
                case .Stars:
                    return p0.avgScore6 > p1.avgScore6
                default:
                    return false
                }
            default:
                return p0.diamonds > p1.diamonds
            }
        })
        tableView?.reloadData()
        tableView?.setContentOffset(CGPointZero, animated:false)
    }

    
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showPicker(sender: AnyObject)
    {
        pickerContainerView?.hidden = false
        selectBtn?.hidden = true
        view.bringSubviewToFront(pickerContainerView!)
    }
    

}

extension ScoresViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scoreSelekcija.scoreValue == .Gc
        {
            if scoreSelekcija.scoreType == .SixDice
            {
                return gcLeaderboard6.scores?.count ?? 0
            }
            else if scoreSelekcija.scoreType == .FiveDice
            {
                return gcLeaderboard5.scores?.count ?? 0
            }
        }
        else
        {
            return sortedPlayers.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! ScoreCell
        if scoreSelekcija.scoreValue == .Gc
        {
            var gkScore: GKScore
            if scoreSelekcija.scoreType == .SixDice
            {
                gkScore = gcLeaderboard6.scores![indexPath.row]
            }
            else
            {
                gkScore = gcLeaderboard5.scores![indexPath.row]
            }
            cell.updateWithGkScore(gkScore, order: indexPath.row+1)
        }
        else
        {
            let playerInfo = sortedPlayers[indexPath.row]
            cell.updateWithPlayerInfo(playerInfo, order: indexPath.row+1)
        }
        
        return cell
    }
}

extension ScoresViewController: ScorePickerDelegate
{
    func doneWithSelekcija() {
        pickerContainerView?.hidden = true
        selectBtn?.hidden = false
        selectBtn?.setTitle(scoreSelekcija.title(), forState: .Normal)
        evaluateBestScores()
        reload()
    }
}
