//
//  ScoreCell.swift
//  Yamb
//
//  Created by Kresimir Prcela on 17/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class ScoreCell: UITableViewCell {

    @IBOutlet weak var orderLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    
    func update(order: Int, score: UInt, stars: Float, name: String, id: String)
    {
        orderLbl.text = String(order)
        nameLbl.text = name
        
        
        switch scoreSelekcija.scoreType
        {
        case .Diamonds:
            scoreLbl.text = "\(score) 💎"
        default:
            scoreLbl.text = String(score)
        }
        
        let localPlayerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)
        
        if id == localPlayerId
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
