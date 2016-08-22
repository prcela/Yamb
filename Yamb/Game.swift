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
    var diceValues: [UInt]?
    var diceHeld = Set<UInt>()
    // table ordered with colIdx, rowIdx
    var tableValues = Array<Array<UInt?>>(count: 5, repeatedValue: Array<UInt?>(count: 16, repeatedValue: nil))
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
        diceHeld.removeAll()
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        printStatus()
    }
    
    func roll()
    {
        guard !(inputState == .Must && inputPos == nil) else {return}
        
        if inputPos != nil
        {
            diceHeld.removeAll()
            DiceScene.shared.updateDiceSelection()
        }
        
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
            
        case .After3:
            gameState = .After1
            inputState = .Allowed
        
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
        var oldValue: UInt?
        if let clearPos = inputPos
        {
            oldValue = tableValues[clearPos.colIdx][clearPos.rowIdx]
            tableValues[clearPos.colIdx][clearPos.rowIdx] = nil
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
        for rowIdx in [
            TableSection.SumNumbers.rawValue,
            TableSection.SumMaxMin.rawValue,
            TableSection.SumSFPY.rawValue]
        {
            tableValues[colIdx][rowIdx] = calculateValueForPos(TablePos(rowIdx: rowIdx, colIdx: colIdx))
        }
    }
    
    func printStatus()
    {
        print(gameState,rollState,inputState,(inputPos != nil ? "\(inputPos!.colIdx) \(inputPos!.rowIdx)" : ""))
    }
    
    func calculateValueForPos(pos: TablePos) -> UInt?
    {
        guard let values = diceValues else {return nil}
        
        let section = TableSection(rawValue: pos.rowIdx)!
        
        switch section
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
            for idxRow in 1...6
            {
                if let value = tableValues[pos.colIdx][idxRow]
                {
                    sum += value
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
            else if section == .Max
            {
                return sum - numMin
            }
            else
            {
                return sum - numMax
            }
            
        case .SumMaxMin:
            if let
            maxValue = tableValues[pos.colIdx][TableSection.Max.rawValue],
            minValue = tableValues[pos.colIdx][TableSection.Min.rawValue],
            oneValue = tableValues[pos.colIdx][TableSection.One.rawValue]
            {
                return (maxValue-minValue)*oneValue
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
                if section == .Poker
                {
                    if sum[value] == 4
                    {
                        return 4*value
                    }
                }
                else if section == .Yamb
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
            for section:TableSection in [.Skala,.Full,.Poker,.Yamb]
            {
                if let value = tableValues[pos.colIdx][section.rawValue]
                {
                    sum += value
                }
            }
            return sum
            
        default:
            return 0
        }
    }
    
    func onDieTouched(dieIdx: UInt)
    {
        guard inputState != .Must && gameState != .Start else {return}
        
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
}