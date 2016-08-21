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

enum GameState
{
    case Start
    case After1
    case After2
    case After3
    case N
    case AfterN2
    case AfterN3
}

enum RollState {
    case Rolling
    case NotRolling
}


enum InputState
{
    case NotAllowed
    case Allowed
    case Must
}

class Game
{
    static let shared = Game()
    
    var diceNum = DiceNum.Five
    var useNajava = true
    var inputState = InputState.NotAllowed
    var gameState = GameState.Start
    var rollState = RollState.NotRolling
    var diceValues: [UInt32]?
    // table ordered with colIdx, rowIdx
    var tableValues = Array<Array<UInt32?>>(count: 5, repeatedValue: Array<UInt32?>(count: 16, repeatedValue: nil))
    var inputPos: TablePos?
    
    var ctColumns: Int {
        get {
            return useNajava ? 5:4
        }
    }
    
    func start()
    {
        gameState = .Start
        rollState = .NotRolling
        inputState = .NotAllowed
        inputPos = nil
        diceValues = nil
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func roll()
    {
        rollState = .Rolling
        inputPos = nil
        DiceScene.shared.roll { (result) in
            self.rollState = .NotRolling
            self.diceValues = result
            self.afterRoll()
        }
    }
    
    func afterRoll()
    {
        switch gameState
        {
        case .Start:
            gameState = .After1
            inputState = .Allowed
        case .After1:
            gameState = .After2
            inputState = .Allowed
        case .After2:
            gameState = .After3
            inputState = .Must
        case .N:
            gameState = .AfterN2
            inputState = .Allowed
        case .AfterN2:
            gameState = .AfterN3
            inputState = .Must
        default:
            print("oops krivo stanje")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func didSelectCellAtPos(pos: TablePos)
    {
        tableValues[pos.colIdx][pos.rowIdx] = 1
        if let clearPos = inputPos
        {
            tableValues[clearPos.colIdx][clearPos.rowIdx] = nil
        }
        inputPos = pos
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
}