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
    
    func updateWithPlayerInfo(playerInfo: PlayerInfo, order: Int)
    {
        var score: UInt = 0
        var stars: Float = 0
        switch scoreSelekcija.scoreType
        {
        case .SixDice:
            switch scoreSelekcija.scoreValue
            {
            case .Score:
                score = playerInfo.maxScore6
            case .Stars:
                stars = (playerInfo.avgScore6 != nil) ? stars6(playerInfo.avgScore6!) : 0
            case .Gc:
                break
            }
            
        case .FiveDice:
            switch scoreSelekcija.scoreValue
            {
            case .Score:
                score = playerInfo.maxScore5
            case .Stars:
                stars = (playerInfo.avgScore5 != nil) ? stars5(playerInfo.avgScore5!) : 0
            default:
                break
            }
            
        case .Diamonds:
            score = UInt(playerInfo.diamonds)
        }
        
        let localPlayerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)
        update(order, score: score, stars: stars, name: playerInfo.alias, selected: playerInfo.id == localPlayerId)
    }
    
    func updateWithGkScore(gkScore: GKScore, order: Int)
    {
        update(order, score: UInt(gkScore.value), stars: 0, name: gkScore.player!.alias!, selected: false)
    }
    
    
    func update(order: Int, score: UInt, stars: Float, name: String, selected: Bool)
    {
        orderLbl.text = String(order)
        nameLbl.text = name
        
        
        if scoreSelekcija.scoreType == .Diamonds
        {
            scoreLbl.text = " 💎\(score)"
        }
        else if scoreSelekcija.scoreValue == .Stars
        {
            scoreLbl.text = String(format: "⭐️ %@", starsFormatter.stringFromNumber(NSNumber(float:stars))!)
        }
        else
        {
            scoreLbl.text = String(score)
        }
        
        if selected
        {
            nameLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
            scoreLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightMedium)
            orderLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
        }
        else
        {
            nameLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
            scoreLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightThin)
            orderLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
        }
        
    }

}
