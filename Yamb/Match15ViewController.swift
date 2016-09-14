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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
            return 1
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
