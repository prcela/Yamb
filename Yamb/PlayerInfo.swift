//
//  PlayerInfo.swift
//  Yamb
//
//  Created by Kresimir Prcela on 16/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class PlayerInfo
{
    var id: String
    var alias: String
    var diamonds: Int
    var avgScore5: Float?
    var avgScore6: Float?
    var connected: Bool
    
    
    init(json: JSON)
    {
        id = json["id"].stringValue
        alias = json["alias"].stringValue
        diamonds = json["diamonds"].intValue
        avgScore5 = json["avg_score_5"].float
        avgScore6 = json["avg_score_6"].float
        connected = json["connected"].boolValue        
    }
}
