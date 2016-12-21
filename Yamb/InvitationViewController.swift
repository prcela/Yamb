//
//  WaitPlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 06/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class InvitationViewController: UIViewController {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var ignoreBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    
    var senderPlayer: Player!
    var shouldSaveSP = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        holderView.layer.cornerRadius = 10
        holderView.clipsToBounds = true
        
        let matchInfo = Room.main.matchesInfo(senderPlayer.id!).first
        
        guard matchInfo != nil,
            let senderPlayer = Room.main.player(senderPlayer.id!) else {
                return
        }
        
        var message = String(format: lstr("Invitation message"), senderPlayer.alias!, matchInfo!.diceNum)
        
        if let bet = matchInfo?.bet, bet > 0
        {
            message += "\n\n"
            message += String(format: lstr("Bet is n"), bet)
        }
        
        if Match.shared.matchType == MatchType.SinglePlayer && PlayViewController.isActive
        {
            let spMatch = Match.shared
            if let player = spMatch.players.first
            {
                if player.state != .start && player.state != .endGame
                {
                    shouldSaveSP = true
                    message += "\n\n"
                    message += lstr("SP progress will be saved")
                }
            }
        }
        
        messageLbl.text = message
        
        ignoreBtn.setTitle(lstr("Ignore"), for: UIControlState())
        acceptBtn.setTitle(lstr("Accept"), for: UIControlState())
        
    }
    
    
    @IBAction func ignore(_ sender: AnyObject)
    {
        WsAPI.shared.ignoreInvitation(senderPlayer.id!)
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func accept(_ sender: AnyObject)
    {
        if shouldSaveSP
        {
            GameFileManager.saveMatch(Match.shared)
        }
        
        if let matchInfo = Room.main.matchesInfo(senderPlayer.id!).first
        {
            if matchInfo.playerIds.count == 1
            {
                // OK
                MainViewController.shared?.dismiss(animated: false, completion: nil)
                WsAPI.shared.joinToMatch(matchInfo.id, ownDiceMat: PlayerStat.shared.favDiceMat)
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func onRoomInfo()
    {
        if let matchInfo = Room.main.matchesInfo(senderPlayer.id!).first
        {
            if matchInfo.playerIds.count == 1
            {
                // OK 
                return
            }
        }

        dismiss(animated: true, completion: nil)
        
    }
    
    
    
}
