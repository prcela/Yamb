//
//  Constants.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

struct Prefs
{
    static let firstRun = "PrefsFirstRun"
    static let finishedOnce = "PrefFinishedOnce"
    static let playerId = "PrefPlayerId"
    static let playerAlias = "PrefPlayerAlias"
    static let playerDiamonds = "PrefPlayerDiamonds"
    static let lastPlayedGameType = "PrefLastPlayedGameType"
    static let ctFinishedMatches6Dice = "PrefCtFinishedMatches6Dice"
    static let avgScore6Dice = "PrefAvgScore6Dice"
    
}

struct LeaderboardId
{
    static let dice5 = "5dice.najava"
    static let dice6 = "6dice.najava"
}

let avgScoreMax6: Float = 1400
let avgScoreMin6: Float = 700
func stars6(avgScore:Float) -> Float
{
    return max(0, 10 * (avgScore-avgScoreMin6)/(avgScoreMax6-avgScoreMin6))
}
