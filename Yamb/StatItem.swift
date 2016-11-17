//
//  StatItem.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class StatItem: NSObject,NSCoding
{
    let playerId: String
    let matchType: MatchType
    let diceNum: DiceNum
    let score: UInt
    let result: Result
    let bet: Int
    let timestamp: NSDate
    
    init(playerId: String, matchType: MatchType, diceNum: DiceNum, score: UInt, result: Result, bet: Int, timestamp: NSDate)
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
        timestamp = NSDate(timeIntervalSince1970: json["timestamp"].doubleValue)
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
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(playerId, forKey: "playerId")
        aCoder.encodeObject(matchType.rawValue, forKey: "matchType")
        aCoder.encodeInteger(diceNum.rawValue, forKey: "diceNum")
        aCoder.encodeInteger(Int(score), forKey: "score")
        aCoder.encodeInteger(result.rawValue, forKey: "result")
        aCoder.encodeInteger(bet, forKey: "bet")
        aCoder.encodeObject(timestamp, forKey: "timestamp")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        playerId = aDecoder.containsValueForKey("playerId") ? aDecoder.decodeObjectForKey("playerId") as! String : ""
        matchType = MatchType(rawValue: aDecoder.decodeObjectForKey("matchType") as! String)!
        diceNum = DiceNum(rawValue: aDecoder.decodeIntegerForKey("diceNum"))!
        score = UInt(aDecoder.decodeIntegerForKey("score"))
        result = Result(rawValue: aDecoder.decodeIntegerForKey("result"))!
        bet = aDecoder.decodeIntegerForKey("bet")
        timestamp = aDecoder.decodeObjectForKey("timestamp") as! NSDate
        super.init()
    }
}
