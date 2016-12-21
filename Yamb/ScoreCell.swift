//
//  ScoreCell.swift
//  Yamb
//
//  Created by Kresimir Prcela on 17/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import GameKit

class ScoreCell: UITableViewCell {

    @IBOutlet weak var orderLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        orderLbl.layer.cornerRadius = 21
        orderLbl.layer.borderColor = UIColor.black.cgColor
        orderLbl.layer.borderWidth = 2
    }
    
    func updateWithPlayerInfo(_ playerInfo: PlayerInfo, order: Int)
    {
        var score: UInt = 0
        var stars: Float = 0
        switch scoreSelekcija.scoreType
        {
        case .sixDice:
            switch scoreSelekcija.scoreValue
            {
            case .score:
                score = playerInfo.maxScore6
            case .stars:
                stars = (playerInfo.avgScore6 != nil) ? stars6(playerInfo.avgScore6!) : 0
            case .gc:
                break
            }
            
        case .fiveDice:
            switch scoreSelekcija.scoreValue
            {
            case .score:
                score = playerInfo.maxScore5
            case .stars:
                stars = (playerInfo.avgScore5 != nil) ? stars5(playerInfo.avgScore5!) : 0
            default:
                break
            }
            
        case .diamonds:
            score = UInt(playerInfo.diamonds)
        }
        
        let localPlayerId = PlayerStat.shared.id
        update(order, score: score, stars: stars, name: playerInfo.alias, selected: playerInfo.id == localPlayerId)
    }
    
    func updateWithGkScore(_ gkScore: GKScore, order: Int)
    {
        let selected = gkScore.player?.playerID == GameKitHelper.shared.localPlayerId
        update(order, score: UInt(gkScore.value), stars: 0, name: gkScore.player!.alias!, selected: selected)
    }
    
    
    func update(_ order: Int, score: UInt, stars: Float, name: String, selected: Bool)
    {
        orderLbl.text = String(order)
        nameLbl.text = name
        
        
        if scoreSelekcija.scoreType == .diamonds
        {
            scoreLbl.text = " 💎\(score)"
        }
        else if scoreSelekcija.scoreValue == .stars
        {
            scoreLbl.text = String(format: "⭐️ %@", starsFormatter.string(from: NSNumber(value: stars as Float))!)
        }
        else
        {
            scoreLbl.text = String(score)
        }
        
        if selected
        {
            nameLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            scoreLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
            orderLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            orderLbl.layer.borderColor = UIColor.black.cgColor
        }
        else
        {
            nameLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightThin)
            scoreLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
            orderLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightThin)
            orderLbl.layer.borderColor = UIColor.clear.cgColor
        }
        
    }

}
