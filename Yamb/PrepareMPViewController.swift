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
    @IBOutlet weak var diceTexBtnFirst: UIButton!
    @IBOutlet weak var diceTexBtnSecond: UIButton!
    @IBOutlet weak var createMatchBtn: UIButton!
    @IBOutlet weak var waitingLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView?
    
    var diceNum: DiceNum = .Six
    var selectedDiceMats = [2,3]
    var playersIgnoredInvitation = [String]()
    var bet = 5
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: #selector(updateFreePlayers), name: NotificationName.onRoomInfo, object: nil)
        nc.addObserver(self, selector: #selector(matchInvitationIgnored(_:)), name: NotificationName.matchInvitationIgnored, object: nil)
        
        let available = NSUserDefaults.standardUserDefaults().integerForKey(Prefs.playerDiamonds)
        bet = min(bet, available)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bacBtn.setTitle(lstr("Back"), forState: .Normal)
        createMatchBtn.setTitle(lstr("Start match"), forState: .Normal)
        waitingLbl.text = lstr("Waiting for opponent player...")
        
        tableView?.hidden = true
        
        for btn in [diceTexBtnFirst,diceTexBtnSecond]
        {
            btn.layer.cornerRadius = 5
            btn.layer.borderColor = UIColor.lightGrayColor().CGColor
            btn.layer.borderWidth = 1
            btn.clipsToBounds = true
        }
        
        updateBetBtn()
        updateDiceBtn()
        updateFreePlayers()
    }
    
    func updateBetBtn()
    {
        betBtn.setTitle(String(format: "%@ 💎 \(bet) ", lstr("Bet")), forState: .Normal)
    }
    
    func updateDiceBtn()
    {
        let title = lstr("Dice 5/6")
        let thinFont = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        let defaultFont = UIFont.systemFontOfSize(30)
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.blackColor()
            ])
        
        let attrStringDisabled = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.grayColor()
            ])
        
        let loc = title.characters.indexOf(diceNum == .Five ? "5":"6")!
        
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        attrStringDisabled.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        dice56Btn?.setAttributedTitle(attrString, forState: .Normal)
        
        dice56Btn.setAttributedTitle(attrStringDisabled, forState: .Disabled)
        
        let btns = [diceTexBtnFirst,diceTexBtnSecond]
        
        for (idx,matIdx) in selectedDiceMats.enumerate()
        {
            let current = diceMats[matIdx]
            btns[idx].setImage(UIImage(named: "1\(current.rawValue)"), forState: .Normal)
        }
    }
    
    func someoneDisconnected()
    {
        WsAPI.shared.roomInfo()
    }
    
    func updateFreePlayers()
    {
        tableView?.reloadData()
    }
    
    func matchInvitationIgnored(notification: NSNotification)
    {
        let recipientPlayerId = notification.object as! String
        playersIgnoredInvitation.append(recipientPlayerId)
        tableView?.reloadData()
    }
    
    func createMatch()
    {
        createMatchBtn.hidden = true
        dice56Btn.enabled = false
        diceTexBtnFirst.enabled = false
        diceTexBtnSecond.enabled = false
        waitingLbl.hidden = false
        activityIndicator.startAnimating()
        tableView?.hidden = false
        betBtn.enabled = false
        decreaseBetBtn.enabled = false
        increaseBetBtn.enabled = false
        
        WsAPI.shared.createMatch(diceNum, diceMaterials: selectedDiceMats.map({ (idx) -> DiceMaterial in
            return diceMats[idx]
        }), bet: bet)
    }
    
    
    @IBAction func back(sender: AnyObject)
    {
        // TODO: leave all my matches
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
        for matchInfo in Room.main.matchesInfo(playerId)
        {
            WsAPI.shared.leaveMatch(matchInfo.id)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func toggleDiceCount(sender: UIButton) {
        diceNum = diceNum == .Five ? .Six : .Five
        updateDiceBtn()
    }
    
    @IBAction func changeFirstDiceMaterial(sender: AnyObject) {
        selectedDiceMats[0] = (selectedDiceMats[0]+1)%diceMats.count
        let diceMat = diceMats[selectedDiceMats[0]]
        diceTexBtnFirst.setImage(UIImage(named: "1\(diceMat.rawValue)"), forState: .Normal)
    }
    
    @IBAction func changeSecondDiceMAterial(sender: AnyObject)
    {
        selectedDiceMats[1] = (selectedDiceMats[1]+1)%diceMats.count
        let diceMat = diceMats[selectedDiceMats[1]]
        diceTexBtnSecond.setImage(UIImage(named: "1\(diceMat.rawValue)"), forState: .Normal)
    }
    
    @IBAction func createMatch(sender: UIButton)
    {
        let available = NSUserDefaults.standardUserDefaults().integerForKey(Prefs.playerDiamonds)
        if available >= bet
        {
            createMatch()
        }
        else
        {
            Chartboost.showRewardedVideo(CBLocationMainMenu)
        }
    }
    
    @IBAction func changeBet(sender: AnyObject)
    {
        increaseBet(sender)
    }
    
    @IBAction func decreaseBet(sender: AnyObject) {
        bet = max(5, bet-5)
        updateBetBtn()
    }
    
    @IBAction func increaseBet(sender: AnyObject) {
        bet += 5
        updateBetBtn()
    }
}

extension PrepareMPViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let player = players()[indexPath.row]
        WsAPI.shared.invitePlayer(player)
    }
}

extension PrepareMPViewController: UITableViewDataSource
{
    func players() -> [Player]
    {
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
        let players = Room.main.freePlayers.filter({ (player) -> Bool in
            return player.id != playerId && !playersIgnoredInvitation.contains(player.id!)
        })
        return players
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return players().count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lstr("Or invite someone")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let player = players()[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! FreePlayerCell
        cell.nameLbl.text = player.alias
        return cell
    }
    
    
}
