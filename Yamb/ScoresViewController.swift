//
//  ScoresViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 13/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import GameKit
import SwiftyJSON

var scoreSelekcija = ScorePickerSelekcija()

class ScoresViewController: UIViewController
{
    
    fileprivate var allPlayers: [String:PlayerInfo]?
    fileprivate var allStatItems: [StatItem]?
    fileprivate var sortedPlayers = [PlayerInfo]()
    fileprivate var filteredItems = [StatItem]()
    fileprivate var gcLeaderboard6 = GKLeaderboard()
    fileprivate var gcLeaderboard5 = GKLeaderboard()
    fileprivate var gcScores5 = [GKScore]()
    fileprivate var gcScores6 = [GKScore]()

    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var selectBtn: UIButton?
    @IBOutlet weak var pickerContainerView: UIView?
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn?.setTitle(lstr("Back"), for: UIControlState())
        selectBtn?.setTitle(scoreSelekcija.title(), for: UIControlState())
        
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
            DispatchQueue.main.async(execute: {
                self?.evaluateBestScores()
                self?.reload(true)
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
            DispatchQueue.main.async(execute: {
                self?.evaluateBestScores()
                self?.reload(true)
            })
        }
        
        // get leaderboard 6 from GC
        gcLeaderboard6.timeScope = GKLeaderboardTimeScope.allTime
        gcLeaderboard6.identifier = LeaderboardId.dice6
        gcLeaderboard6.range = NSMakeRange(1, 100)
        gcLeaderboard6.loadScores { [weak self] (scores, error) in
            if error != nil
            {
                print(error!)
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    self?.gcScores6.append(contentsOf: scores!)
                    self?.reload(true)
                })
            }
        }
        
        // get leaderboard 5 from GC
        gcLeaderboard5.timeScope = GKLeaderboardTimeScope.allTime
        gcLeaderboard5.identifier = LeaderboardId.dice5
        gcLeaderboard5.range = NSMakeRange(1, 100)
        gcLeaderboard5.loadScores { [weak self] (scores, error) in
            if error != nil
            {
                print(error!)
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    self?.gcScores5.append(contentsOf: scores!)
                    self?.reload(true)
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPicker"
        {
            let scorePickerVC = segue.destination as! ScorePickerViewController
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
        
        let day: TimeInterval = 24*60*60
        for statItem in allStatItems!
        {
            let timeInterval = Date().timeIntervalSince(statItem.timestamp as Date)
            
            switch scoreSelekcija.timeRange
            {
            case .week:
                if timeInterval > 7*day
                {
                    continue
                }
            
            case .today:
                if timeInterval > day
                {
                    continue
                }
            default:
                break
            }
            
            if let playerInfo = allPlayers![statItem.playerId]
            {
                if statItem.diceNum == .five
                {
                    if playerInfo.maxScore5 < statItem.score
                    {
                        playerInfo.maxScore5 = statItem.score
                    }
                }
                else if statItem.diceNum == .six
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
    
    func reload(_ scrollToTop: Bool)
    {
        sortedPlayers.sort(by: { (p0, p1) -> Bool in
            switch scoreSelekcija.scoreType
            {
            case .fiveDice:
                switch scoreSelekcija.scoreValue
                {
                case .score:
                    return p0.maxScore5 > p1.maxScore5
                case .stars:
                    return (p0.avgScore5 ?? 0) > (p1.avgScore5 ?? 0)
                default:
                    return false
                }
                
            case .sixDice:
                switch scoreSelekcija.scoreValue
                {
                case .score:
                    return p0.maxScore6 > p1.maxScore6
                case .stars:
                    return (p0.avgScore6 ?? 0) > (p1.avgScore6 ?? 0)
                default:
                    return false
                }
            default:
                return p0.diamonds > p1.diamonds
            }
        })
        tableView?.reloadData()
        if scrollToTop
        {
            tableView?.setContentOffset(CGPoint.zero, animated:false)
        }
    }

    
    @IBAction func back(_ sender: AnyObject)
    {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPicker(_ sender: AnyObject)
    {
        pickerContainerView?.isHidden = false
        selectBtn?.isHidden = true
        view.bringSubview(toFront: pickerContainerView!)
    }
    

}

extension ScoresViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scoreSelekcija.scoreValue == .gc
        {
            if scoreSelekcija.scoreType == .sixDice
            {
                return gcScores6.count
            }
            else if scoreSelekcija.scoreType == .fiveDice
            {
                return gcScores5.count
            }
        }
        else
        {
            return sortedPlayers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! ScoreCell
        if scoreSelekcija.scoreValue == .gc
        {
            var gkScore: GKScore
            if scoreSelekcija.scoreType == .sixDice
            {
                gkScore = gcScores6[indexPath.row]
            }
            else
            {
                gkScore = gcScores5[indexPath.row]
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

extension ScoresViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if scoreSelekcija.scoreValue == .gc
        {
            if scoreSelekcija.scoreType == .sixDice
            {
                let count = gcScores6.count
                if count == indexPath.row+1 && count < gcLeaderboard6.maxRange
                {
                    gcLeaderboard6.range = NSMakeRange(count+1,100)
                    gcLeaderboard6.loadScores { [weak self] (scores, error) in
                        if error != nil
                        {
                            print(error!)
                        }
                        else
                        {
                            DispatchQueue.main.async(execute: {
                                self?.gcScores6.append(contentsOf: scores!)
                                self?.reload(false)
                            })
                        }
                    }
                }
            }
            else if scoreSelekcija.scoreType == .fiveDice
            {
                let count = gcScores5.count
                if count == indexPath.row+1 && count < gcLeaderboard5.maxRange
                {
                    gcLeaderboard5.range = NSMakeRange(count+1,100)
                    gcLeaderboard5.loadScores { [weak self] (scores, error) in
                        if error != nil
                        {
                            print(error!)
                        }
                        else
                        {
                            DispatchQueue.main.async(execute: {
                                self?.gcScores5.append(contentsOf: scores!)
                                self?.reload(false)
                            })
                        }
                    }
                }
            }
        }
    }
}

extension ScoresViewController: ScorePickerDelegate
{
    func doneWithSelekcija() {
        pickerContainerView?.isHidden = true
        selectBtn?.isHidden = false
        selectBtn?.setTitle(scoreSelekcija.title(), for: UIControlState())
        evaluateBestScores()
        reload(true)
    }
}
