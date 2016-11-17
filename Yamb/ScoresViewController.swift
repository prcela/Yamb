//
//  ScoresViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 13/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

var scoreSelekcija = ScorePickerSelekcija()

class ScoresViewController: UIViewController
{
    
    private var allPlayers: [String:PlayerInfo]?
    private var allStatItems: [StatItem]?
    private var sortedPlayers = [PlayerInfo]()

    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var selectBtn: UIButton?
    @IBOutlet weak var pickerContainerView: UIView?
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn?.setTitle(lstr("Back"), forState: .Normal)
        selectBtn?.setTitle(scoreSelekcija.title(), forState: .Normal)
        
        // proba .... get all players
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
        for statItem in allStatItems!
        {
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
                    return false // TODO
                }
                
            case .SixDice:
                switch scoreSelekcija.scoreValue
                {
                case .Score:
                    return p0.maxScore6 > p1.maxScore6
                case .Stars:
                    return p0.avgScore6 > p1.avgScore6
                default:
                    return false // TODO
                }
            default:
                return p0.diamonds > p1.diamonds
            }
        })
        tableView?.reloadData()
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
        return sortedPlayers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! ScoreCell
        let playerInfo = sortedPlayers[indexPath.row]
        var score: UInt = 0
        var stars: Float = 0
        switch scoreSelekcija.scoreType
        {
        case .SixDice:
            switch scoreSelekcija.scoreValue
            {
            case .Score:
                score = playerInfo.maxScore6
            case .Stars:
                stars = (playerInfo.avgScore6 != nil) ? stars6(playerInfo.avgScore6!) : 0
            default:
                break
            }
            
        case .FiveDice:
            switch scoreSelekcija.scoreValue
            {
            case .Score:
                score = playerInfo.maxScore5
            case .Stars:
                stars = (playerInfo.avgScore5 != nil) ? stars5(playerInfo.avgScore5!) : 0
            default:
                break
            }
            
        case .Diamonds:
            score = UInt(playerInfo.diamonds)
        }
        cell.update(indexPath.row+1, score: score, stars: stars, name: playerInfo.alias)
        return cell
    }
}

extension ScoresViewController: ScorePickerDelegate
{
    func doneWithSelekcija() {
        pickerContainerView?.hidden = true
        selectBtn?.hidden = false
        selectBtn?.setTitle(scoreSelekcija.title(), forState: .Normal)
        reload()
    }
}
