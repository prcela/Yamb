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
    let matchType: MatchType
    let diceNum: DiceNum
    let score: UInt
    let result: Result
    let bet: Int
    let timestamp: NSDate
    
    init(matchType: MatchType, diceNum: DiceNum, score: UInt, result: Result, bet: Int, timestamp: NSDate)
    {
        self.matchType = matchType
        self.diceNum = diceNum
        self.score = score
        self.result = result
        self.bet = bet
        self.timestamp = timestamp
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(matchType.rawValue, forKey: "matchType")
        aCoder.encodeInteger(diceNum.rawValue, forKey: "diceNum")
        aCoder.encodeInteger(Int(score), forKey: "score")
        aCoder.encodeInteger(result.rawValue, forKey: "result")
        aCoder.encodeInteger(bet, forKey: "bet")
        aCoder.encodeObject(timestamp, forKey: "timestamp")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        matchType = MatchType(rawValue: aDecoder.decodeObjectForKey("matchType") as! String)!
        diceNum = DiceNum(rawValue: aDecoder.decodeIntegerForKey("diceNum"))!
        score = UInt(aDecoder.decodeIntegerForKey("score"))
        result = Result(rawValue: aDecoder.decodeIntegerForKey("result"))!
        bet = aDecoder.decodeIntegerForKey("bet")
        timestamp = aDecoder.decodeObjectForKey("timestamp") as! NSDate
        super.init()
    }
}
