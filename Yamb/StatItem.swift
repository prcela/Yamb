//
//  StatItem.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import SwiftyJSON

class StatItem: NSObject,NSCoding
{
    let playerId: String
    let matchType: MatchType
    let diceNum: DiceNum
    let score: UInt
    let result: Result
    let bet: Int
    let timestamp: Date
    
    init(playerId: String, matchType: MatchType, diceNum: DiceNum, score: UInt, result: Result, bet: Int, timestamp: Date)
    {
        self.playerId = playerId
        self.matchType = matchType
        self.diceNum = diceNum
        self.score = score
        self.result = result
        self.bet = bet
        self.timestamp = timestamp
    }
    
    init(json: JSON)
    {
        playerId = json["player_id"].stringValue
        matchType = MatchType(rawValue: json["match_type"].stringValue)!
        diceNum = DiceNum(rawValue: json["dice_num"].intValue)!
        score = json["score"].uIntValue
        result = Result(rawValue: json["result"].intValue)!
        bet = json["bet"].intValue
        timestamp = Date(timeIntervalSince1970: json["timestamp"].doubleValue)
    }
    
    func json() -> JSON
    {
        return JSON([
            "player_id": playerId,
            "match_type": matchType.rawValue,
            "dice_num": diceNum.rawValue,
            "score": score,
            "result": result.rawValue,
            "bet": bet,
            "timestamp": timestamp.timeIntervalSince1970
            ])
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(playerId, forKey: "playerId")
        aCoder.encode(matchType.rawValue, forKey: "matchType")
        aCoder.encode(diceNum.rawValue, forKey: "diceNum")
        aCoder.encode(Int(score), forKey: "score")
        aCoder.encode(result.rawValue, forKey: "result")
        aCoder.encode(bet, forKey: "bet")
        aCoder.encode(timestamp, forKey: "timestamp")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        playerId = aDecoder.containsValue(forKey: "playerId") ? aDecoder.decodeObject(forKey: "playerId") as! String : ""
        matchType = MatchType(rawValue: aDecoder.decodeObject(forKey: "matchType") as! String)!
        diceNum = DiceNum(rawValue: aDecoder.decodeInteger(forKey: "diceNum"))!
        score = UInt(aDecoder.decodeInteger(forKey: "score"))
        result = Result(rawValue: aDecoder.decodeInteger(forKey: "result"))!
        bet = aDecoder.decodeInteger(forKey: "bet")
        timestamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
        super.init()
    }
}
