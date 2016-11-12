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
    static let playerId = "PrefPlayerId"
    static let playerAlias = "PrefPlayerAlias"
    static let lastPlayedGameType = "PrefLastPlayedGameType"
}

struct LeaderboardId
{
    static let dice5 = "5dice.najava"
    static let dice6 = "6dice.najava"
}

func allDiceMaterials() -> [DiceMaterial]
{
    return [.White, .Black, .Blue, .Rose, .Red, .Yellow]
}


let avgScoreMax6: Float = 1400
let avgScoreMin6: Float = 700
func stars6(avgScore:Float) -> Float
{
    return max(0, 10 * (avgScore-avgScoreMin6)/(avgScoreMax6-avgScoreMin6))
}

let starsFormatter = NSNumberFormatter()

func helloSwift()
{
    #if swift(>=3.0)
        print("Hello, Swift 3!")
    #elseif swift(>=2.3)
        print("Hello, Swift 2.3!")
    #elseif swift(>=2.1)
        print("Hello, Swift 2.1!")
    #endif
}
