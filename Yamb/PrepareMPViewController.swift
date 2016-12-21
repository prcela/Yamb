//
//  PrepareMPViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PrepareMPViewController: UIViewController {

    @IBOutlet weak var bacBtn: UIButton!
    @IBOutlet weak var dice56Btn: UIButton!
    @IBOutlet weak var betBtn: UIButton!
    @IBOutlet weak var decreaseBetBtn: UIButton!
    @IBOutlet weak var increaseBetBtn: UIButton!
    @IBOutlet weak var createMatchBtn: UIButton!
    @IBOutlet weak var lockBtn: UIButton!
    @IBOutlet weak var waitingLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var lockInfoLbl: UILabel?
    
    var diceNum: DiceNum = .six
    var invitedPlayers = Set<String>()
    var playersIgnoredInvitation = Set<String>()
    var bet = 5
    var isPrivate = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(updateFreePlayers), name: NotificationName.onRoomInfo, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationIgnored(_:)), name: NotificationName.matchInvitationIgnored, object: nil)
        
        let available = PlayerStat.shared.diamonds
        bet = min(bet, available)
        bet = max(5, bet)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bacBtn.setTitle(lstr("Back"), for: UIControlState())
        createMatchBtn.setTitle(lstr("Start match"), for: UIControlState())
        waitingLbl.text = lstr("Waiting for opponent player...")
        lockInfoLbl?.text = lstr("Only invited players can play")
        
        tableView?.isHidden = true
        
        updateBetBtn()
        updateDiceBtn()
        updatePrivateBtn()
        updateFreePlayers()
    }
    
    func updatePrivateBtn()
    {
        lockBtn.setTitle(isPrivate ? "🔒":"🔓", for: UIControlState())
    }
    
    func updateBetBtn()
    {
        betBtn.setTitle(String(format: "%@ 💎 \(bet) ", lstr("Bet")), for: UIControlState())
    }
    
    func updateDiceBtn()
    {
        let title = lstr("Dice 5/6")
        let thinFont = UIFont.systemFont(ofSize: 30, weight: UIFontWeightThin)
        let defaultFont = UIFont.systemFont(ofSize: 30)
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.black
            ])
        
        let attrStringDisabled = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.gray
            ])
        
        let loc = title.characters.index(of: diceNum == .five ? "5":"6")!
        
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.characters.distance(from: title.startIndex, to: loc), 1))
        
        attrStringDisabled.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.characters.distance(from: title.startIndex, to: loc), 1))
        
        dice56Btn?.setAttributedTitle(attrString, for: UIControlState())
        
        dice56Btn.setAttributedTitle(attrStringDisabled, for: .disabled)
        
    }
    
    func someoneDisconnected()
    {
        WsAPI.shared.roomInfo()
    }
    
    func updateFreePlayers()
    {
        tableView?.reloadData()
    }
    
    func matchInvitationIgnored(_ notification: Notification)
    {
        let recipientPlayerId = notification.object as! String
        playersIgnoredInvitation.insert(recipientPlayerId)
        tableView?.reloadData()
    }
    
    func createMatch()
    {
        createMatchBtn.isHidden = true
        dice56Btn.isEnabled = false
        waitingLbl.isHidden = isPrivate
        activityIndicator.startAnimating()
        tableView?.isHidden = false
        betBtn.isEnabled = false
        decreaseBetBtn.isEnabled = false
        increaseBetBtn.isEnabled = false
        lockBtn.isHidden = true
        lockInfoLbl?.isHidden = true
        
        let favDiceMat = PlayerStat.shared.favDiceMat
        WsAPI.shared.createMatch(diceNum, isPrivate: isPrivate, diceMaterials: [favDiceMat, .White], bet: bet)
    }
    
    
    @IBAction func back(_ sender: AnyObject)
    {
        // TODO: leave all my matches
        let playerId = PlayerStat.shared.id
        for matchInfo in Room.main.matchesInfo(playerId)
        {
            WsAPI.shared.leaveMatch(matchInfo.id)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toggleDiceCount(_ sender: UIButton) {
        diceNum = diceNum == .five ? .six : .five
        updateDiceBtn()
    }
    
    @IBAction func createMatch(_ sender: UIButton)
    {
        let available = PlayerStat.shared.diamonds
        if available >= bet
        {
            createMatch()
        }
        else
        {
            suggestRewardVideo()
        }
    }
    
    
    @IBAction func togglePrivate(_ sender: AnyObject)
    {
        isPrivate = !isPrivate
        updatePrivateBtn()
        
        lockInfoLbl?.isHidden = !isPrivate
    }
    
    @IBAction func changeBet(_ sender: AnyObject)
    {
        increaseBet(sender)
    }
    
    @IBAction func decreaseBet(_ sender: AnyObject) {
        bet = max(5, bet-5)
        updateBetBtn()
    }
    
    @IBAction func increaseBet(_ sender: AnyObject) {
        let available = PlayerStat.shared.diamonds
        if bet + 5 <= available
        {
            bet += 5
            updateBetBtn()
        }
        else
        {
            suggestRewardVideo()
        }
    }
}

extension PrepareMPViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let player = players()[indexPath.row]
        if player.diamonds >= bet
        {
            WsAPI.shared.invitePlayer(player)
            invitedPlayers.insert(player.id!)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        else
        {
            let message = String(format: lstr("PlayerX has not enough"), player.alias!)
            let alert = UIAlertController(title: "Yamb", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension PrepareMPViewController: UITableViewDataSource
{
    func players() -> [Player]
    {
        let playerId = PlayerStat.shared.id
        let players = Room.main.freePlayers().filter({ (player) -> Bool in
            return player.id != playerId && player.connected && !playersIgnoredInvitation.contains(player.id!)
        })
        return players
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return players().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lstr("Or invite someone")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let player = players()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! FreePlayerCell
        cell.nameLbl.text = String(format: "%@ ⭐️ %d 💎 %@", starsFormatter.string(from: NSNumber(value: stars6(player.avgScore6) as Float))!, player.diamonds, player.alias!)
        tableView.tintColor = UIColor.darkGray
        cell.accessoryType = invitedPlayers.contains(player.id!) ? .checkmark : .none
        return cell
    }
    
    
}
