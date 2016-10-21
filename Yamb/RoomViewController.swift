//
//  Match15ViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 08/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController
{
    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var tableView: UITableView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
        nc.addObserver(self, selector: #selector(joinedMatch(_:)), name: NotificationName.joinedMatch, object: nil)
        nc.addObserver(self, selector: #selector(popToHere), name: NotificationName.goToMainRoom, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn?.setTitle(lstr("Back"), forState: .Normal)
        // Do any additional setup after loading the view.
        WsAPI.shared.connect()
    }
    
    func onRoomInfo()
    {
        print("window: \(tableView?.window)")
        tableView?.reloadData()
    }
    
    func joinedMatch(notification: NSNotification)
    {
        let matchId = notification.object as! UInt
        if let idx = Room.main.matchesInfo.indexOf ({ (m) -> Bool in
            return m.id == matchId
        }) {
            let matchInfo = Room.main.matchesInfo[idx]
            let firstPlayer = matchInfo.players.first!
            let lastPlayer = matchInfo.players.last!
            Match.shared.start(.OnlineMultiplayer,
                               diceNum: DiceNum(rawValue: matchInfo.diceNum)!,
                               playersDesc: [
                                (firstPlayer.id,firstPlayer.alias,DiceMaterial(rawValue: matchInfo.diceMaterials.first!)!),
                                (lastPlayer.id,lastPlayer.alias,DiceMaterial(rawValue: matchInfo.diceMaterials.last!)!)],
                               matchId: matchId)
            navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
        }
    }
    
    func popToHere()
    {
        navigationController?.popToViewController(self, animated: false)
    }
    
    
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
}

extension RoomViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // create match
        // waiting matches
        // free players
        // matches
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles:[String?] = [
            nil,
            lstr("Free matches"),
            lstr("Free players"),
            lstr("Active matches")]
        return titles[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
        let isFreePlayer = Room.main.freePlayers.contains({ (player) -> Bool in
            return player.id == playerId
        })
        
        if section == 0
        {
            // allow match creation for free players only
            if isFreePlayer
            {
                return 1
            }
            return 0
        }
        else if section == 1
        {
            let waitingMatches = Room.main.matchesInfo(.WaitingForPlayers)
            return waitingMatches.count
        }
        else if section == 2
        {
            let players = Room.main.freePlayers.filter({ (player) -> Bool in
                return player.id != playerId
            })
            return players.count
        }
        else
        {
            let playingMatches = Room.main.matchesInfo(.Playing)
            return playingMatches.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellId")!
            cell.textLabel?.text = lstr("Create new match")
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("MatchCellId") as! MatchCell
            let waitingMatches = Room.main.matchesInfo(.WaitingForPlayers)
            let match = waitingMatches[indexPath.row]
            cell.diceIconFirst.image = UIImage(named: "1\(match.diceMaterials.first!)")
            cell.diceIconSecond.image = UIImage(named: "2\(match.diceMaterials.last!)")
            cell.titleLbl?.text = "\(match.diceNum) \(match.players.first!.alias!)"
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        else if indexPath.section == 2
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellId")!
            let player = Room.main.freePlayers.filter({ (player) -> Bool in
                return player.id != playerId
            })[indexPath.row]
            cell.textLabel?.text = player.alias
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("MatchCellId") as! MatchCell
            let playingMatches = Room.main.matchesInfo(.Playing)
            let match = playingMatches[indexPath.row]
            let firstPlayer = match.players.first!
            let lastPlayer = match.players.last!
            cell.titleLbl?.text = firstPlayer.alias! + " - " + lastPlayer.alias!
            return cell
        }
        
    }
    
    
}

extension RoomViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0
        {
            performSegueWithIdentifier("prepareMP", sender: self)
        }
        else if indexPath.section == 1
        {
            let filteredMatches = Room.main.matchesInfo.filter({ (match) -> Bool in
                return match.state == .WaitingForPlayers
            })
            let match = filteredMatches[indexPath.row]
            WsAPI.shared.joinToMatch(match.id)
        }
    }
}
