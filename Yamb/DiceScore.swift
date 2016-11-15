//
//  DiceScore.swift
//  Yamb
//
//  Created by Kresimir Prcela on 14/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class DiceScore
{
    var score: Int32
    var timestamp: NSDate
    var stars: Double
    var avg_score: Double
    
    init?(json: JSON)
    {
        guard !json.isEmpty else {
            return nil
        }
        score = json["score"].int32Value
        timestamp = NSDate(timeIntervalSince1970: json["timestamp"].doubleValue)
        stars = json["stars"].doubleValue
        avg_score = json["avg_score"].doubleValue
    }
}
