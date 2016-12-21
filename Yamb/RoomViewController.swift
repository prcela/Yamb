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
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
        nc.addObserver(self, selector: #selector(popToHere), name: NotificationName.goToMainRoom, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn?.setTitle(lstr("Back"), for: UIControlState())
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
    
    
    @IBAction func back(_ sender: AnyObject)
    {
        navigationController?.popViewController(animated: true)
    }
    
}

extension RoomViewController: UITableViewDataSource
{
    func freeMatches() -> [MatchInfo]
    {
        let filteredMatches = Room.main.matchesInfo.filter({ (match) -> Bool in
            return match.state == .WaitingForPlayers && !match.isPrivate
        })
        return filteredMatches
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        // create match
        // waiting matches
        // free players
        // matches
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles:[String?] = [
            nil,
            lstr("Free matches"),
            lstr("Free players"),
            lstr("Active matches")]
        return titles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let playerId = PlayerStat.shared.id
        let isFreePlayer = Room.main.freePlayers().contains(where: { (player) -> Bool in
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
            return freeMatches().count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let playerId = PlayerStat.shared.id
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellId")!
            cell.textLabel?.text = lstr("Create new match")
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCellId") as! MatchCell
            let match = freeMatches()[indexPath.row]
            cell.updateWithWaitingMatch(match)
            return cell
        }
        else if indexPath.section == 2
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellId")!
            let player = Room.main.freePlayers().filter({ (player) -> Bool in
                return player.id != playerId && player.connected
            })[indexPath.row]
            let stars = starsFormatter.string(from: NSNumber(value: stars6(player.avgScore6) as Float))!
            cell.textLabel?.text = String(format: "%@ ⭐️  %@", stars, player.alias!)
            cell.accessoryType = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCellId") as! MatchCell
            let playingMatches = Room.main.matchesInfo(.Playing)
            let match = playingMatches[indexPath.row]
            cell.updateWithPlayingMatch(match)
            return cell
        }
        
    }
    
    
}

extension RoomViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0
        {
            performSegue(withIdentifier: "prepareMP", sender: self)
        }
        else if indexPath.section == 1
        {
            
            let match = freeMatches()[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        let alert = UIAlertController(title: "Yamb", message: lstr("Not enough diamonds, look reward"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lstr("No"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: lstr("Yes"), style: .default, handler: { (action) in
            DispatchQueue.main.async(execute: {
                Chartboost.showRewardedVideo(CBLocationMainMenu)
            })
        }))
        present(alert, animated: true, completion: nil)
    }
}
