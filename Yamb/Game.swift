//
//  Game.swift
//  Yamb
//
//  Created by prcela on 16/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

struct NotificationName
{
    static let gameStateChanged = "Notification.GameStateChanged"
    static let play = "Notification.Play"
}

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
    var tableValues = Array<Array<UInt32?>>(count: 4, repeatedValue: Array<UInt32?>(count: 16, repeatedValue: nil))
    
    func start()
    {
        gameState = .Start
        rollState = .NotRolling
        diceValues = nil
        DiceScene.shared.start()
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
}