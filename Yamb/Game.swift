//
//  Game.swift
//  Yamb
//
//  Created by prcela on 16/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import Firebase

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
    
    var diceNum = DiceNum.Six
    var inputState = InputState.NotAllowed
    var state = GameState.Start
    var rollState = RollState.NotRolling
    var diceValues: [UInt]?
    var diceHeld = Set<UInt>() {
        didSet {
            DiceScene.shared.updateDiceSelection()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        }
    }
    
    var table = Table()
    var inputPos: TablePos?
    
    var ctColumns = 6
    
    func start()
    {
        state = .Start
        rollState = .NotRolling
        inputState = .NotAllowed
        inputPos = nil
        diceValues = nil
        diceHeld.removeAll()
        table.resetValues()
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        printStatus()
        FIRAnalytics.logEventWithName("game_start", parameters: ["dice_num": diceNum.rawValue])
    }
    
    func roll()
    {
        guard !(inputState == .Must && inputPos == nil) else {return}
        
        if inputPos != nil
        {
            if inputPos!.colIdx != TableCol.N.rawValue
            {
                switch state
                {
                case .After1, .After2, .After3, .AfterN3:
                    state = .Start
                    diceHeld.removeAll()
                    inputPos = nil
                default:
                    break
                }
            }
            
            if state == .AfterN3 || state == .After3
            {
                diceHeld.removeAll()
                inputPos = nil
            }
        }
        
        rollState = .Rolling
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        
        DiceScene.shared.roll { (result) in
            self.rollState = .NotRolling
            self.diceValues = result
            self.afterRoll()
        }
    }
    
    func afterRoll()
    {
        switch state
        {
        case .Start:
            state = .After1
            inputState = .Allowed
            inputPos = nil
        
        case .After1:
            if inputPos == nil
            {
                state = .After2
                inputState = .Allowed
            }
            else if inputPos!.colIdx == TableCol.N.rawValue
            {
                state = .AfterN2
                inputState = .NotAllowed
                updateNajavaValue()
            }
            
        case .After2:
            if inputPos == nil
            {
                state = .After3
                inputState = .Must
                diceHeld.removeAll()
            }
            else
            {
                state = .After1
                inputState = .Allowed
                inputPos = nil
            }
            
        case .After3:
            state = .After1
            inputState = .Allowed
            inputPos = nil
            diceHeld.removeAll()
            
        case .AfterN2:
            state = .AfterN3
            inputState = .NotAllowed
            updateNajavaValue()
            diceHeld.removeAll()
            
        case .AfterN3:
            state = .After1
            inputState = .Allowed
            updateNajavaValue()
            inputPos = nil
            diceHeld.removeAll()
        }
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func updateNajavaValue()
    {
        if let pos = inputPos
        {
            table.updateValue(pos, diceValues: diceValues)
            table.recalculateSumsForColumn(pos.colIdx, diceValues: diceValues)
            if table.isQualityValueFor(pos, diceValues: diceValues)
            {
                state = .AfterN3
                inputState = .NotAllowed
                diceHeld.removeAll()
            }
        }
    }
    
    func didSelectCellAtPos(pos: TablePos)
    {
        var oldValue: UInt?
        if let clearPos = inputPos
        {
            oldValue = table.values[clearPos.colIdx][clearPos.rowIdx]
            table.values[clearPos.colIdx][clearPos.rowIdx] = nil
            table.recalculateSumsForColumn(clearPos.colIdx, diceValues: diceValues)
        }
        
        if pos != inputPos
        {
            inputPos = pos
            table.updateValue(pos, diceValues: diceValues)
        }
        else if oldValue == nil
        {
            table.updateValue(pos, diceValues: diceValues)
        }
        else
        {
            // obrisana stara vrijednost
            inputPos = nil
        }
        
        table.recalculateSumsForColumn(pos.colIdx, diceValues: diceValues)
                
        if state == .After3 || state == .AfterN3
        {
            diceHeld.removeAll()
        }
        
        if pos.colIdx == TableCol.N.rawValue
        {
            updateNajavaValue()
        }
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    
    
    func printStatus()
    {
        print(state,rollState,inputState,(inputPos != nil ? "\(inputPos!.colIdx) \(inputPos!.rowIdx)" : ""))
    }
    
    
    
    func onDieTouched(dieIdx: UInt)
    {
        guard inputState != .Must && state != .Start else {return}
        
        if diceHeld.contains(dieIdx)
        {
            diceHeld.remove(dieIdx)
        }
        else
        {
            diceHeld.insert(dieIdx)
        }
    }
    
    func isRollEnabled() -> Bool
    {
        if inputState == .Must && inputPos == nil
        {
            return false
        }
        
        if rollState == .Rolling
        {
            return false
        }
                
        if diceHeld.count == diceNum.rawValue
        {
            return false
        }
        return true
    }
    
    
}