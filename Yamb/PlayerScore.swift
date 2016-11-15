//
//  PlayerScore.swift
//  Yamb
//
//  Created by Kresimir Prcela on 14/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class PlayerScore
{
    var player_id: String
    var alias: String
    var diamonds: Int32
    
    var dice5: DiceScore?
    var dice6: DiceScore?
    
    var ct_matches_sp = 0
    var ct_matches_mp = 0
    
 
    init(json: JSON)
    {
        player_id = json["player_id"].stringValue
        alias = json["alias"].stringValue
        diamonds = json["diamonds"].int32Value
        
        dice5 = DiceScore(json: json["5"])
        dice6 = DiceScore(json: json["6"])
    }

}
