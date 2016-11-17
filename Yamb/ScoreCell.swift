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
    
    
    func update(order: Int, score: UInt, stars: Float, name: String)
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
        
    }

}
