//
//  Table.swift
//  Yamb
//
//  Created by Kresimir Prcela on 26/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

private let keyValue = "keyValue"

class Table: NSObject, NSCoding
{
    // table ordered with colIdx, rowIdx
    var values = Array<Array<UInt?>>(count: 6, repeatedValue: Array<UInt?>(count: 16, repeatedValue: nil))
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        for (idxCol,col) in values.enumerate()
        {
            for (idxRow,row) in col.enumerate()
            {
                if row != nil
                {
                    aCoder.encodeInteger(Int(row!), forKey:"\(keyValue) \(idxCol) \(idxRow)")
                }
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        for idxCol in 0..<6
        {
            for idxRow in 0..<16
            {
                let key = "\(keyValue) \(idxCol) \(idxRow)"
                if aDecoder.containsValueForKey(key)
                {
                    values[idxCol][idxRow] = UInt(aDecoder.decodeIntegerForKey(key))
                }
            }
        }
        super.init()
    }

    
    func resetValues()
    {
        values = Array<Array<UInt?>>(count: 6, repeatedValue: Array<UInt?>(count: 16, repeatedValue: nil))
    }
    
    func updateValue(pos: TablePos, diceValues: [UInt]?) -> UInt?
    {
        let newValue = calculateValueForPos(pos, diceValues: diceValues)
        values[pos.colIdx][pos.rowIdx] = newValue
        
        if Game.shared.gameType == .OnlineMultiplayer && Game.shared.isLocalPlayerTurn()
        {
            var params = JSON(["posColIdx":pos.colIdx, "posRowIdx":pos.rowIdx])
            params["value"].uInt = newValue
            WsAPI.shared.turn(.SetValueAtTablePos, matchId: Game.shared.matchId, params: params)
        }
        
        return newValue
    }
    
    func calculateValueForPos(pos: TablePos, diceValues: [UInt]?) -> UInt?
    {
        guard let diceValues = diceValues else {return nil}
        
        let row = TableRow(rawValue: pos.rowIdx)!
        
        switch row
        {
        case .One, .Two, .Three, .Four, .Five, .Six:
            var ct:UInt = 0
            for value in diceValues
            {
                if value == UInt(pos.rowIdx)
                {
                    ct += 1
                }
            }
            return min(5, ct) * UInt(pos.rowIdx)
            
        case .SumNumbers:
            
            var sum: UInt?
            if pos.colIdx == TableCol.Sum.rawValue
            {
                for col:TableCol in [.Down,.Up,.UpDown,.N]
                {
                    if let value = values[col.rawValue][pos.rowIdx]
                    {
                        if sum == nil
                        {
                            sum = 0
                        }
                        sum! += value
                    }
                }
            }
            else
            {
                for idxRow in 1...6
                {
                    if let value = values[pos.colIdx][idxRow]
                    {
                        if sum == nil
                        {
                            sum = 0
                        }
                        sum! += value
                    }
                }
                if sum >= 60
                {
                    sum! += 30
                }
            }
            return sum
            
            
        case .Max, .Min:
            
            let numMax = diceValues.reduce(UInt.min, combine: { max($0, $1) })
            let numMin = diceValues.reduce(UInt.max, combine: { min($0, $1) })
            
            let sum = diceValues.reduce(0, combine: { (sum, value) -> UInt in
                return sum + value
            })
            
            if diceValues.count == 5
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
                var sum:UInt?
                
                for col:TableCol in [.Down,.Up,.UpDown,.N]
                {
                    if let value = values[col.rawValue][pos.rowIdx]
                    {
                        if sum == nil {
                            sum = 0
                        }
                        sum! += value
                    }
                }
                return sum
            }
            else
            {
                if let
                    maxValue = values[pos.colIdx][TableRow.Max.rawValue],
                    let minValue = values[pos.colIdx][TableRow.Min.rawValue],
                    let oneValue = values[pos.colIdx][TableRow.One.rawValue]
                {
                    return (maxValue-minValue)*oneValue
                }
            }
            return nil
            
        case .Skala:
            let set = Set(diceValues)
            
            if set.intersect([2,3,4,5,6]).count == 5
            {
                return 40
            }
            else if set.intersect([1,2,3,4,5]).count == 5
            {
                return 30
            }
            return 0
            
        case .Full:
            
            var sum = [UInt:UInt]()
            var atLeastPairs = [UInt]()
            for value in diceValues
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
                    return 30 + atLeastPairs[0]*2 + atLeastPairs[1]*3
                }
                else
                {
                    return 30 + atLeastPairs[0]*3 + atLeastPairs[1]*2
                }
            }
            else if atLeastPairs.count == 1 && sum[atLeastPairs[0]] >= 5
            {
                // yamb može biti isto full
                return 30 + 5*atLeastPairs[0]
            }
            
            return 0
            
        case .Poker, .Yamb:
            
            var sum = [UInt:UInt]()
            for value in diceValues
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
                        return 40 + 4*value
                    }
                }
                else if row == .Yamb
                {
                    if sum[value] == 5
                    {
                        return 50 + 5*value
                    }
                }
            }
            
            return 0
            
        case .SumSFPY:
            var sum:UInt?
            if pos.colIdx == TableCol.Sum.rawValue
            {
                for col:TableCol in [.Down,.Up,.UpDown,.N]
                {
                    if let value = values[col.rawValue][pos.rowIdx]
                    {
                        if sum == nil
                        {
                            sum = 0
                        }
                        sum! += value
                    }
                }
            }
            else
            {
                for row:TableRow in [.Skala,.Full,.Poker,.Yamb]
                {
                    if let value = values[pos.colIdx][row.rawValue]
                    {
                        if sum == nil
                        {
                            sum = 0
                        }
                        sum! += value
                    }
                }
            }
            return sum
            
        default:
            return 0
        }
    }
    
    func isQualityValueFor(pos: TablePos, diceValues: [UInt]?) -> Bool
    {
        guard let value = values[pos.colIdx][pos.rowIdx] else {return false}
        
        switch TableRow(rawValue: pos.rowIdx)! {
        case .One,.Two,.Three,.Four,.Five,.Six:
            return value == 5*UInt(pos.rowIdx)
        case .Max:
            return value == 5*6
        case .Min:
            return value == 5
        case .Skala:
            return value == 40
        case .Full:
            return value >= 58 || (diceValues != nil && diceValues!.count == 5 && value > 0)
        case .Poker:
            return value > 0
        case .Yamb:
            return value > 0
        default:
            return false
        }
    }
    
    func recalculateSumsForColumn(colIdx: Int, diceValues: [UInt]?)
    {
        let sumRows:[TableRow] = [.SumNumbers,.SumMaxMin,.SumSFPY]
        let sumColIdx = TableCol.Sum.rawValue
        for row in sumRows
        {
            updateValue(TablePos(rowIdx: row.rawValue, colIdx: colIdx), diceValues: diceValues)
            updateValue(TablePos(rowIdx: row.rawValue, colIdx: sumColIdx), diceValues: diceValues)
        }
    }
    
    func fakeFill()
    {
        for row:TableRow in [.One, .Two, .Three, .Four, .Five, .Six, .Max, .Min, .Skala, .Full, .Poker, .Yamb]
        {
            for col:TableCol in [.Down, .Up, .UpDown, .N]
            {
                values[col.rawValue][row.rawValue] = 1
            }
        }
        values[1][1] = nil
        values[4][1] = nil
    }
    
    func areFulfilled(cols:[TableCol]) -> Bool
    {
        for row:TableRow in [.One, .Two, .Three, .Four, .Five, .Six, .Max, .Min, .Skala, .Full, .Poker, .Yamb]
        {
            for col in cols
            {
                if values[col.rawValue][row.rawValue] == nil
                {
                    return false
                }
            }
        }
        return true
    }
    
    func totalScore() -> UInt?
    {
        var sum: UInt?
        let sumColIdx = TableCol.Sum.rawValue
        for row:TableRow in [.SumNumbers,.SumMaxMin,.SumSFPY]
        {
            if let value = values[sumColIdx][row.rawValue]
            {
                if sum == nil
                {
                    sum = 0
                }
                sum! += value
            }
        }
        return sum
    }
    
}
