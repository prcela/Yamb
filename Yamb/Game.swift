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
    
    var diceNum = DiceNum.Five
    var useNajava = true
    var inputState = InputState.NotAllowed
    var state = GameState.Start
    var rollState = RollState.NotRolling
    var diceValues: [UInt]?
    var diceHeld = Set<UInt>()
    // table ordered with colIdx, rowIdx
    var tableValues = Array<Array<UInt?>>(count: 6, repeatedValue: Array<UInt?>(count: 16, repeatedValue: nil))
    var inputPos: TablePos?
    
    var ctColumns: Int {
        get {
            return useNajava ? 6:5
        }
    }
    
    func start()
    {
        state = .Start
        rollState = .NotRolling
        inputState = .NotAllowed
        inputPos = nil
        diceValues = nil
        diceHeld.removeAll()
        tableValues = Array<Array<UInt?>>(count: 6, repeatedValue: Array<UInt?>(count: 16, repeatedValue: nil))
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        printStatus()
        FIRAnalytics.logEventWithName("game_start", parameters: ["najava": useNajava, "dice_num": diceNum.rawValue])
    }
    
    func roll()
    {
        guard !(inputState == .Must && inputPos == nil) else {return}
        
        if inputPos != nil && inputPos!.colIdx != TableCol.N.rawValue || (state == .AfterN3 || state == .After3)
        {
            diceHeld.removeAll()
            DiceScene.shared.updateDiceSelection()
            inputPos = nil
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
            
        case .AfterN2:
            state = .AfterN3
            inputState = .NotAllowed
            updateNajavaValue()
            
        case .AfterN3:
            state = .After1
            inputState = .Allowed
            updateNajavaValue()
            inputPos = nil
            diceHeld.removeAll()
            DiceScene.shared.updateDiceSelection()
        }
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func updateNajavaValue()
    {
        if let pos = inputPos
        {
            tableValues[pos.colIdx][pos.rowIdx] = calculateValueForPos(pos)
            recalculateSumsForColumn(pos.colIdx)
        }
    }
    
    func didSelectCellAtPos(pos: TablePos)
    {
        var oldValue: UInt?
        if let clearPos = inputPos
        {
            oldValue = tableValues[clearPos.colIdx][clearPos.rowIdx]
            tableValues[clearPos.colIdx][clearPos.rowIdx] = nil
            recalculateSumsForColumn(clearPos.colIdx)
        }
        
        if pos != inputPos
        {
            inputPos = pos
            tableValues[pos.colIdx][pos.rowIdx] = calculateValueForPos(pos)
        }
        else if oldValue == nil
        {
            tableValues[pos.colIdx][pos.rowIdx] = calculateValueForPos(pos)
        }
        else
        {
            // obrisana stara vrijednost
            inputPos = nil
        }
        
        recalculateSumsForColumn(pos.colIdx)
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func recalculateSumsForColumn(colIdx: Int)
    {
        let sumRows:[TableRow] = [.SumNumbers,.SumMaxMin,.SumSFPY]
        let sumColIdx = TableCol.Sum.rawValue
        for row in sumRows
        {
            tableValues[colIdx][row.rawValue] = calculateValueForPos(TablePos(rowIdx: row.rawValue, colIdx: colIdx))
            tableValues[sumColIdx][row.rawValue] = calculateValueForPos(TablePos(rowIdx: row.rawValue, colIdx: sumColIdx))
        }
    }
    
    func printStatus()
    {
        print(state,rollState,inputState,(inputPos != nil ? "\(inputPos!.colIdx) \(inputPos!.rowIdx)" : ""))
    }
    
    func calculateValueForPos(pos: TablePos) -> UInt?
    {
        guard let values = diceValues else {return nil}
        
        let row = TableRow(rawValue: pos.rowIdx)!
        
        switch row
        {
        case .One, .Two, .Three, .Four, .Five, .Six:
            return values.reduce(0, combine: { (sum, value) -> UInt in
                if value == UInt(pos.rowIdx)
                {
                    return sum + value
                }
                return sum
            })
            
        case .SumNumbers:
            
            var sum: UInt = 0
            if pos.colIdx == TableCol.Sum.rawValue
            {
                for col:TableCol in [.Down,.Up,.UpDown,.N]
                {
                    if let value = tableValues[col.rawValue][pos.rowIdx]
                    {
                        sum += value
                    }
                }
            }
            else
            {
                for idxRow in 1...6
                {
                    if let value = tableValues[pos.colIdx][idxRow]
                    {
                        sum += value
                    }
                }
            }
            return sum
            
            
        case .Max, .Min:
            
            let numMax = values.reduce(UInt.min, combine: { max($0, $1) })
            let numMin = values.reduce(UInt.max, combine: { min($0, $1) })
            
            let sum = values.reduce(0, combine: { (sum, value) -> UInt in
                    return sum + value
            })
            
            if diceNum == .Five
            {
                return sum
            }
            else if row == .Max
            {
                return sum - numMin
            }
            else
            {
                return sum - numMax
            }
            
        case .SumMaxMin:
            if pos.colIdx == TableCol.Sum.rawValue
            {
                var sum:UInt = 0
                
                for col:TableCol in [.Down,.Up,.UpDown,.N]
                {
                    if let value = tableValues[col.rawValue][pos.rowIdx]
                    {
                        sum += value
                    }
                }
                return sum
            }
            else
            {
                if let
                    maxValue = tableValues[pos.colIdx][TableRow.Max.rawValue],
                    minValue = tableValues[pos.colIdx][TableRow.Min.rawValue],
                    oneValue = tableValues[pos.colIdx][TableRow.One.rawValue]
                {
                    return (maxValue-minValue)*oneValue
                }
            }
            return nil
            
        case .Skala:
            let set = Set(values)
            
            if set.intersect([1,2,3,4,5]).count == 5
            {
                return 30
            }
            else if set.intersect([2,3,4,5,6]).count == 5
            {
                return 40
            }
            return 0
            
        case .Full:
            
            var sum = [UInt:UInt]()
            var atLeastPairs = [UInt]()
            for value in values
            {
                if sum[value] == nil
                {
                    sum[value] = 0
                }
                sum[value]! += 1
            }
            
            for (key,value) in sum
            {
                if value >= 2
                {
                    atLeastPairs.append(key)
                }
            }
            
            if atLeastPairs.count == 2 && (sum[atLeastPairs[0]] >= 3 || sum[atLeastPairs[1]] >= 3)
            {
                atLeastPairs.sortInPlace()
                if sum[atLeastPairs[1]] >= 3
                {
                    return atLeastPairs[0]*2 + atLeastPairs[1]*3
                }
                else
                {
                    return atLeastPairs[0]*3 + atLeastPairs[1]*2
                }
            }
            else if atLeastPairs.count == 1 && sum[atLeastPairs[0]] >= 5
            {
                // yamb može biti isto full
                return 5*atLeastPairs[0]
            }
            
            return 0
        
        case .Poker, .Yamb:
            
            var sum = [UInt:UInt]()
            for value in values
            {
                if sum[value] == nil
                {
                    sum[value] = 0
                }
                sum[value]! += 1
                if row == .Poker
                {
                    if sum[value] == 4
                    {
                        return 4*value
                    }
                }
                else if row == .Yamb
                {
                    if sum[value] == 5
                    {
                        return 5*value
                    }
                }
            }
            
            return 0
            
        case .SumSFPY:
            var sum:UInt = 0
            if pos.colIdx == TableCol.Sum.rawValue
            {
                for col:TableCol in [.Down,.Up,.UpDown,.N]
                {
                    if let value = tableValues[col.rawValue][pos.rowIdx]
                    {
                        sum += value
                    }
                }
            }
            else
            {
                for row:TableRow in [.Skala,.Full,.Poker,.Yamb]
                {
                    if let value = tableValues[pos.colIdx][row.rawValue]
                    {
                        sum += value
                    }
                }
            }
            return sum
            
        default:
            return 0
        }
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
        
        DiceScene.shared.updateDiceSelection()
    }
    
    func totalScore() -> UInt
    {
        var sum: UInt = 0
        let sumColIdx = TableCol.Sum.rawValue
        for row:TableRow in [.SumNumbers,.SumMaxMin,.SumSFPY]
        {
            if let value = tableValues[sumColIdx][row.rawValue]
            {
                sum += value
            }
        }
        return sum
    }
}