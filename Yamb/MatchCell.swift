//
//  MatchCell.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

    @IBOutlet weak var diceIconFirst: UIImageView!
    @IBOutlet weak var diceIconSecond: UIImageView!
    
    @IBOutlet weak var titleLbl1: UILabel?
    @IBOutlet weak var titleLbl2: UILabel?
    
    @IBOutlet weak var infoLbl1: UILabel?
    @IBOutlet weak var infoLbl2: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for icon in [diceIconFirst,diceIconSecond]
        {
            icon.layer.cornerRadius = 2.5
            icon.layer.borderColor = UIColor.lightGrayColor().CGColor
            icon.layer.borderWidth = 0.5
            icon.clipsToBounds = true
        }
    }
    
    func updateWithWaitingMatch(match: MatchInfo)
    {
        let player = match.players.first!
        diceIconFirst.image = UIImage(named: "1\(match.diceMaterials.first!)")
        diceIconSecond.image = UIImage(named: "2\(match.diceMaterials.last!)")
        let stars = stars6(player.avgScore6)
        titleLbl1?.text = String(format: "%@ ⭐️ %@", starsFormatter.stringFromNumber(NSNumber(float: stars))!, player.alias!)
        titleLbl2?.text = "?"
        infoLbl1?.text = "\(match.diceNum) 🎲"
        infoLbl2?.text = "\(match.bet) 💎"
        accessoryType = .DisclosureIndicator
    }
    
    func updateWithPlayingMatch(match: MatchInfo)
    {
        let firstPlayer = match.players.first!
        let lastPlayer = match.players.last!
        diceIconFirst.image = UIImage(named: "1\(match.diceMaterials.first!)")
        diceIconSecond.image = UIImage(named: "2\(match.diceMaterials.last!)")
        titleLbl1?.text = String(format: "%@ ⭐️ %@", starsFormatter.stringFromNumber(NSNumber(float: stars6(firstPlayer.avgScore6)))!, firstPlayer.alias!)
        titleLbl2?.text = String(format: "%@ ⭐️ %@", starsFormatter.stringFromNumber(NSNumber(float: stars6(lastPlayer.avgScore6)))!, lastPlayer.alias!)
        infoLbl1?.text = "\(match.diceNum) 🎲"
        infoLbl2?.text = "\(match.bet) 💎"
        accessoryType = .None
    }

}
