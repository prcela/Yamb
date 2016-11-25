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
        let isFreePlayer = Room.main.freePlayers().contains({ (player) -> Bool in
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
            let players = Room.main.freePlayers().filter({ (player) -> Bool in
                return player.id != playerId && player.connected
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
            cell.updateWithWaitingMatch(match)
            return cell
        }
        else if indexPath.section == 2
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellId")!
            let player = Room.main.freePlayers().filter({ (player) -> Bool in
                return player.id != playerId && player.connected
            })[indexPath.row]
            cell.textLabel?.text = String(format: "%@ ⭐️ %@", starsFormatter.stringFromNumber(NSNumber(float: stars6(player.avgScore6)))!, player.alias!)
            cell.accessoryType = .None
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("MatchCellId") as! MatchCell
            let playingMatches = Room.main.matchesInfo(.Playing)
            let match = playingMatches[indexPath.row]
            cell.updateWithPlayingMatch(match)
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
            let available = PlayerStat.shared.diamonds
            if available >= match.bet
            {
                WsAPI.shared.joinToMatch(match.id, ownDiceMat: PlayerStat.shared.favDiceMat)
            }
            else
            {
                suggestRewardVideo()
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if [1,3].contains(indexPath.section)
        {
            return 70
        }
        return tableView.rowHeight
    }
}

/// Allow this to be called from any controller
extension UIViewController
{
    func suggestRewardVideo()
    {
        let alert = UIAlertController(title: "Yamb", message: lstr("Not enough diamonds, look reward"), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: lstr("No"), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: lstr("Yes"), style: .Default, handler: { (action) in
            dispatch_async(dispatch_get_main_queue(), {
                Chartboost.showRewardedVideo(CBLocationMainMenu)
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}
