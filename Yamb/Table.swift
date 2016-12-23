//
//  Table.swift
//  Yamb
//
//  Created by Kresimir Prcela on 26/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import SwiftyJSON

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


private let keyValue = "keyValue"

class Table: NSObject, NSCoding
{
    // table ordered with colIdx, rowIdx
    var values = [[UInt?]](repeating: [UInt?](repeating: nil, count: 16), count: 6)
    
    func encode(with aCoder: NSCoder)
    {
        for (idxCol,col) in values.enumerated()
        {
            for (idxRow,row) in col.enumerated()
            {
                if row != nil
                {
                    aCoder.encode(Int(row!), forKey:"\(keyValue) \(idxCol) \(idxRow)")
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
                if aDecoder.containsValue(forKey: key)
                {
                    values[idxCol][idxRow] = UInt(aDecoder.decodeInteger(forKey: key))
                }
            }
        }
        super.init()
    }

    
    func resetValues()
    {
        values = [[UInt?]](repeating: [UInt?](repeating: nil, count: 16), count: 6)
    }
    
    func updateValue(atPos pos: TablePos, diceValues: [UInt]?) -> UInt?
    {
        let newValue = calculateValueForPos(pos, diceValues: diceValues)
        values[pos.colIdx][pos.rowIdx] = newValue
        
        if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
        {
            var params = JSON(["posColIdx":pos.colIdx, "posRowIdx":pos.rowIdx])
            params["value"].uInt = newValue
            WsAPI.shared.turn(.setValueAtTablePos, matchId: Match.shared.id, params: params)
        }
        
        return newValue
    }
    
    func calculateValueForPos(_ pos: TablePos, diceValues: [UInt]?) -> UInt?
    {
        guard let diceValues = diceValues else {return nil}
        
        let row = TableRow(rawValue: pos.rowIdx)!
        
        switch row
        {
        case .one, .two, .three, .four, .five, .six:
            var ct:UInt = 0
            for value in diceValues
            {
                if value == UInt(pos.rowIdx)
                {
                    ct += 1
                }
            }
            return min(5, ct) * UInt(pos.rowIdx)
            
        case .sumNumbers:
            
            var sum: UInt?
            if pos.colIdx == TableCol.sum.rawValue
            {
                for col:TableCol in [.down,.up,.upDown,.n]
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
            
            
        case .max, .min:
            
            let numMax = diceValues.reduce(UInt.min, { max($0, $1) })
            let numMin = diceValues.reduce(UInt.max, { min($0, $1) })
            
            let sum = diceValues.reduce(0, { (sum, value) -> UInt in
                return sum + value
            })
            
            if diceValues.count == 5
            {
                return sum
            }
            else if row == .max
            {
                return sum - numMin
            }
            else
            {
                return sum - numMax
            }
            
        case .sumMaxMin:
            if pos.colIdx == TableCol.sum.rawValue
            {
                var sum:UInt?
                
                for col:TableCol in [.down,.up,.upDown,.n]
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
                    maxValue = values[pos.colIdx][TableRow.max.rawValue],
                    let minValue = values[pos.colIdx][TableRow.min.rawValue],
                    let oneValue = values[pos.colIdx][TableRow.one.rawValue]
                {
                    return (maxValue-minValue)*oneValue
                }
            }
            return nil
            
        case .skala:
            let set = Set(diceValues)
            
            if set.intersection([2,3,4,5,6]).count == 5
            {
                return 40
            }
            else if set.intersection([1,2,3,4,5]).count == 5
            {
                return 30
            }
            return 0
            
        case .full:
            
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
                atLeastPairs.sort()
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
            
        case .poker, .yamb:
            
            var sum = [UInt:UInt]()
            for value in diceValues
            {
                if sum[value] == nil
                {
                    sum[value] = 0
                }
                sum[value]! += 1
                if row == .poker
                {
                    if sum[value] == 4
                    {
                        return 40 + 4*value
                    }
                }
                else if row == .yamb
                {
                    if sum[value] == 5
                    {
                        return 50 + 5*value
                    }
                }
            }
            
            return 0
            
        case .sumSFPY:
            var sum:UInt?
            if pos.colIdx == TableCol.sum.rawValue
            {
                for col:TableCol in [.down,.up,.upDown,.n]
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
                for row:TableRow in [.skala,.full,.poker,.yamb]
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
    
    func isQualityValueFor(_ pos: TablePos, diceValues: [UInt]?) -> Bool
    {
        guard let value = values[pos.colIdx][pos.rowIdx] else {return false}
        
        switch TableRow(rawValue: pos.rowIdx)! {
        case .one,.two,.three,.four,.five,.six:
            return value == 5*UInt(pos.rowIdx)
        case .max:
            return value == 5*6
        case .min:
            return value == 5
        case .skala:
            return value == 40
        case .full:
            return value >= 58 || (diceValues != nil && diceValues!.count == 5 && value > 0)
        case .poker:
            return value > 0
        case .yamb:
            return value > 0
        default:
            return false
        }
    }
    
    func recalculateSums(atCol colIdx: Int, diceValues: [UInt]?)
    {
        let sumRows:[TableRow] = [.sumNumbers,.sumMaxMin,.sumSFPY]
        let sumColIdx = TableCol.sum.rawValue
        for row in sumRows
        {
            let _ = updateValue(atPos: TablePos(rowIdx: row.rawValue, colIdx: colIdx), diceValues: diceValues)
            let _ = updateValue(atPos: TablePos(rowIdx: row.rawValue, colIdx: sumColIdx), diceValues: diceValues)
        }
    }
    
    func fakeFill()
    {
        for row:TableRow in [.one, .two, .three, .four, .five, .six, .max, .min, .skala, .full, .poker, .yamb]
        {
            for col:TableCol in [.down, .up, .upDown, .n]
            {
                values[col.rawValue][row.rawValue] = 1
            }
        }
        values[1][1] = nil
        values[4][1] = nil
    }
    
    func areFulfilled(_ cols:[TableCol]) -> Bool
    {
        for row:TableRow in [.one, .two, .three, .four, .five, .six, .max, .min, .skala, .full, .poker, .yamb]
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
        let sumColIdx = TableCol.sum.rawValue
        for row:TableRow in [.sumNumbers,.sumMaxMin,.sumSFPY]
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
    
    func fillAnyEmptyPos() -> Bool
    {
        for row:TableRow in [.one, .two, .three, .four, .five, .six, .max, .min, .skala, .full, .poker, .yamb]
        {
            for col:TableCol in [.down,.up,.upDown,.n]
            {
                if values[col.rawValue][row.rawValue] == nil
                {
                    // worse value
                    var newValue:UInt = 0
                    if row == .min
                    {
                        newValue = 30
                    }
                    values[col.rawValue][row.rawValue] = newValue
                    
                    if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
                    {
                        var params = JSON(["posColIdx":col.rawValue, "posRowIdx":row.rawValue])
                        params["value"].uInt = newValue
                        WsAPI.shared.turn(.setValueAtTablePos, matchId: Match.shared.id, params: params)
                    }
                    return true
                }
            }
        }
        return false
    }
    
}
