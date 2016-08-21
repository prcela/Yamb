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
        printStatus()
    }
    
    func roll()
    {
        rollState = .Rolling
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
            if inputPos == nil
            {
                gameState = .After2
                inputState = .Allowed
            }
            
        case .After2:
            if inputPos == nil
            {
                gameState = .After3
                inputState = .Must
            }
            else
            {
                gameState = .After1
                inputState = .Allowed
            }
        case .N:
            gameState = .AfterN2
            inputState = .Allowed
        case .AfterN2:
            gameState = .AfterN3
            inputState = .Must
        default:
            print("oops krivo stanje")
        }
        
        inputPos = nil
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func didSelectCellAtPos(pos: TablePos)
    {
        var oldValue: UInt32?
        if let clearPos = inputPos
        {
            oldValue = tableValues[clearPos.colIdx][clearPos.rowIdx]
            tableValues[clearPos.colIdx][clearPos.rowIdx] = nil
        }
        
        if pos != inputPos
        {
            inputPos = pos
            tableValues[pos.colIdx][pos.rowIdx] = 1
        }
        else if oldValue == nil
        {
            tableValues[pos.colIdx][pos.rowIdx] = 1
        }
        else
        {
            // obrisana stara vrijednost
            inputPos = nil
        }
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func printStatus()
    {
        print(gameState,rollState,inputState,(inputPos != nil ? "\(inputPos!.colIdx) \(inputPos!.rowIdx)" : ""))
    }
}