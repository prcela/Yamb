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

class Game
{
    static let shared = Game()
    
    var diceNum = DiceNum.Five
    var useNajava = true
    
    func start()
    {
        DiceScene.shared.start()
    }
}