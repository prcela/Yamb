//
//  Game.swift
//  Yamb
//
//  Created by prcela on 16/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum DiceNum: Int
{
    case Five = 5
    case Six = 6
}

enum RollState
{
    case Start
    case After1
    case After2
    case After3
    case N
    case AfterN1
    case AfterN2
    case AfterN3
}

class Game
{
    static let shared = Game()
    
    var diceNum = DiceNum.Five
    var useNajava = true
    var rollState = RollState.Start
    
    
    func start()
    {
        rollState = .Start
        DiceScene.shared.start()
    }
}