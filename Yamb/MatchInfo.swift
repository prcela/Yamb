//
//  Match.swift
//  Yamb
//
//  Created by Kresimir Prcela on 12/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
enum MatchState: String
{
    case WaitingForPlayers = "Waiting"
    case Playing = "Playing"
    case Finished = "Finished"
}

class MatchInfo
{
    var id:UInt = 0
    var state:MatchState = .WaitingForPlayers
    var bet:Int = 0
    var players = [Player]()
    var diceNum: Int = 6
    var diceMaterials = ["a","b"]
    
}
