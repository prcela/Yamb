//
//  Constants.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import StoreKit

struct Prefs
{
    static let playerId_Deprecated = "PrefPlayerId"
    static let playerAlias_Deprecated = "PrefPlayerAlias"
    static let lastPlayedGameType = "PrefLastPlayedGameType"
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

let avgScoreMax5: Float = 1200
let avgScoreMin5: Float = 400
func stars5(avgScore:Float) -> Float
{
    return max(0, 10 * (avgScore-avgScoreMin5)/(avgScoreMax5-avgScoreMin5))
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

var retrievedProducts: Set<SKProduct>?

let purchaseNameId = "yamb.PurchaseName"
let purchaseDiceGId = "yamb.PurchaseDice.g"
let purchaseDicePId = "yamb.PurchaseDice.p"
let purchaseDiceLId = "yamb.PurchaseDice.l"

let allPurchaseIds: Set<String> = [purchaseNameId, purchaseDiceGId, purchaseDiceLId, purchaseDicePId]
