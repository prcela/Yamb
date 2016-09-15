//
//  Match15ViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 08/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class Match15ViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
        nc.addObserver(self, selector: #selector(joinedMatch(_:)), name: NotificationName.joinedMatch, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        WsAPI.shared.connect()
    }
    
    func onRoomInfo()
    {
        tableView?.reloadData()
    }
    
    func joinedMatch(notification: NSNotification)
    {
        let matchId = notification.object as! UInt
        if let idx = Room.main.matches.indexOf ({ (m) -> Bool in
            return m.id == matchId
        }) {
            let match = Room.main.matches[idx]
            let firstPlayer = match.players.first!
            let lastPlayer = match.players.last!
            Game.shared.start(GameType.OnlineMultiplayer, playersDesc: [(firstPlayer.id,DiceMaterial.Blue),(lastPlayer.id,DiceMaterial.Red)])
            navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
        }
        
        
    }

    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
}

extension Match15ViewController: UITableViewDataSource
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
        
        if section == 0
        {
            // allow match creation for free players only
            
            if Room.main.freePlayers.contains({ (player) -> Bool in
                return player.id == playerId
            }) {
                return 1
            }
            return 0
        }
        else if section == 1
        {
            let filteredMatches = Room.main.matches.filter({ (match) -> Bool in
                return match.state == .WaitingForPlayers
            })
            return filteredMatches.count
        }
        else if section == 2
        {
            return Room.main.freePlayers.count
        }
        else
        {
            let filteredMatches = Room.main.matches.filter({ (match) -> Bool in
                return match.state == .Playing
            })
            return filteredMatches.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId")!
        
        if indexPath.section == 0
        {
            cell.textLabel?.text = lstr("Create new match")
        }
        else if indexPath.section == 1
        {
            let filteredMatches = Room.main.matches.filter({ (match) -> Bool in
                return match.state == .WaitingForPlayers
            })
            let match = filteredMatches[indexPath.row]
            cell.textLabel?.text = match.players.first!.alias
        }
        else if indexPath.section == 2
        {
            let player = Room.main.freePlayers[indexPath.row]
            cell.textLabel?.text = player.alias
        }
        else
        {
            let filteredMatches = Room.main.matches.filter({ (match) -> Bool in
                return match.state == .Playing
            })
            let match = filteredMatches[indexPath.row]
            let firstPlayer = match.players.first!
            let lastPlayer = match.players.last!
            cell.textLabel?.text = firstPlayer.alias! + " - " + lastPlayer.alias!
        }
        
        return cell
        
    }
}

extension Match15ViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0
        {
            WsAPI.shared.createMatch()
        }
        else if indexPath.section == 1
        {
            let filteredMatches = Room.main.matches.filter({ (match) -> Bool in
                return match.state == .WaitingForPlayers
            })
            let match = filteredMatches[indexPath.row]
            WsAPI.shared.joinToMatch(match.id)
        }
    }
}
