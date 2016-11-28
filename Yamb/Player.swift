//
//  Player.swift
//  Yamb
//
//  Created by Kresimir Prcela on 30/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit
import Firebase

private let keyId = "letKeyId"
private let keyTable = "keyTable"
private let keyInputState = "keyInputState"
private let keyState = "keyState"
private let keyRollState = "keyRollState"
private let keyDiceValues = "keyDiceValues"
private let keyDiceHeld = "keyDiceHeld"
private let keyInputPosRow = "keyInputPosRow"
private let keyInputPosCol = "keyInputPosCol"
private let keyDiceMaterial = "keyDiceMaterial"

enum PlayerState: Int
{
    case Start = 0
    case After1
    case After2
    case After3
    case AfterN2
    case AfterN3
    case WaitTurn
    case EndGame
}



enum RollState: Int {
    case Rolling = 0
    case NotRolling
}


enum InputState: Int
{
    case NotAllowed = 0
    case Allowed
    case Must
}



class Player: NSObject, NSCoding
{
    var id: String?
    var alias: String?
    var avgScore6: Float = 0
    var diamonds: Int = 0
    var connected = false
    var diceMaterial = DiceMaterial.White
    var table = Table()
    var inputState = InputState.NotAllowed
    var state = PlayerState.Start
    var rollState = RollState.NotRolling
    var diceValues: [UInt]?
    var diceHeld = Set<UInt>() {
        didSet {
            DiceScene.shared.updateDiceSelection()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
            
            if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
            {
                let params = JSON(Array(diceHeld))
                WsAPI.shared.turn(.HoldDice, matchId: Match.shared.id, params: params)
            }
        }
    }
    var activeRotationRounds = [[Int]](count: 6, repeatedValue: [0,0,0])
    
    var inputPos: TablePos? {
        didSet {
            if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
            {
                var params = JSON([:])
                if inputPos != nil
                {
                    params["colIdx"].intValue = inputPos!.colIdx
                    params["rowIdx"].intValue = inputPos!.rowIdx
                }
                WsAPI.shared.turn(.InputPos, matchId: Match.shared.id, params: params)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey(keyId) as? String
        table = aDecoder.decodeObjectForKey(keyTable) as! Table
        inputState = InputState(rawValue: aDecoder.decodeIntegerForKey(keyInputState))!
        state = PlayerState(rawValue: aDecoder.decodeIntegerForKey(keyState))!
        rollState = RollState(rawValue: aDecoder.decodeIntegerForKey(keyRollState))!
        diceValues = aDecoder.decodeObjectForKey(keyDiceValues) as? [UInt]
        diceHeld = (aDecoder.decodeObjectForKey(keyDiceHeld) as? Set<UInt>)!
        
        if aDecoder.containsValueForKey(keyInputPosRow)
        {
            let row = aDecoder.decodeIntegerForKey(keyInputPosRow)
            let col = aDecoder.decodeIntegerForKey(keyInputPosCol)
            inputPos = TablePos(rowIdx: row, colIdx: col)
        }
        diceMaterial = DiceMaterial(rawValue: aDecoder.decodeObjectForKey(keyDiceMaterial) as? String ?? "a")!

        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(id, forKey: keyId)
        aCoder.encodeObject(table, forKey: keyTable)
        aCoder.encodeInteger(inputState.rawValue, forKey: keyInputState)
        aCoder.encodeInteger(state.rawValue, forKey: keyState)
        aCoder.encodeInteger(rollState.rawValue, forKey: keyRollState)
        aCoder.encodeObject(diceValues, forKey: keyDiceValues)
        aCoder.encodeObject(diceHeld, forKey: keyDiceHeld)
        
        if let pos = inputPos
        {
            aCoder.encodeInteger(pos.rowIdx, forKey: keyInputPosRow)
            aCoder.encodeInteger(pos.colIdx, forKey: keyInputPosCol)
        }
        aCoder.encodeObject(diceMaterial.rawValue, forKey: keyDiceMaterial)

    }
    
    func next()
    {
        state = .WaitTurn
        inputPos = nil
        diceHeld.removeAll()
        inputState = .NotAllowed
    }
    
    func onTurn()
    {
        inputPos = nil
        diceHeld.removeAll()
        inputState = .NotAllowed
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
                case .After1, .After2, .After3, .AfterN3, .WaitTurn:
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
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
        
        let ctMaxRounds: UInt32 = 3
        var oldValues = diceValues
        var values = [UInt]()
        
        for dieIdx in 0..<Match.shared.diceNum.rawValue
        {
            if diceHeld.contains(UInt(dieIdx))
            {
                // skip it by adding same value
                values.append(oldValues?[dieIdx] ?? 1)
                continue
            }
            
            let num = UInt(1+arc4random_uniform(6))
            values.append(num)
            
            var newRounds = [Int(1+arc4random_uniform(ctMaxRounds)),
                             Int(1+arc4random_uniform(ctMaxRounds)),
                             Int(1+arc4random_uniform(ctMaxRounds))]
            
            
            for (idx,_) in newRounds.enumerate()
            {
                while newRounds[idx] == activeRotationRounds[dieIdx][idx] {
                    let dir = arc4random_uniform(2) == 0 ? -1:1
                    newRounds[idx] = dir*Int(1+arc4random_uniform(ctMaxRounds))
                }
                activeRotationRounds[dieIdx][idx] = newRounds[idx]
            }
        }
        
        if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
        {
            let params = JSON(["values":values,"rounds":activeRotationRounds])
            WsAPI.shared.turn(.RollDice, matchId: Match.shared.id, params: params)
        }
        
        DiceScene.shared.rollToValues(values, ctMaxRounds: ctMaxRounds) {
            self.rollState = .NotRolling
            self.diceValues = values
            self.afterRoll()
        }
    }
    
    func afterRoll()
    {
        switch state
        {
        case .Start, .WaitTurn:
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
            if shouldEnd()
            {
                end()
            }
            
        case .AfterN3:
            updateNajavaValue()
            state = .After1
            inputState = .Allowed
            inputPos = nil
            diceHeld.removeAll()
            
        case .EndGame:
            break
        }
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
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
        if let oldPos = inputPos
        {
            oldValue = table.values[oldPos.colIdx][oldPos.rowIdx]
            if state == .AfterN2
            {
                state = .AfterN3
            }
            else
            {
                table.values[oldPos.colIdx][oldPos.rowIdx] = nil
                table.recalculateSumsForColumn(oldPos.colIdx, diceValues: diceValues)
                
                if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
                {
                    var params = JSON(["posColIdx":oldPos.colIdx, "posRowIdx":oldPos.rowIdx])
                    params["value"].uInt = nil
                    WsAPI.shared.turn(.SetValueAtTablePos, matchId: Match.shared.id, params: params)
                }
            }
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
        
        if shouldEnd()
        {
            // kraj
            end()
        }
        
        printStatus()
    }
    
    func forceAnyTurn() -> Bool
    {
        return table.fillAnyEmptyPos()
    }
    
    func shouldEnd() -> Bool
    {
        if state == .EndGame
        {
            // already finished
            return false
        }
        
        if !table.areFulfilled([.Down, .Up, .UpDown, .N])
        {
            return false
        }
        
        if state == .AfterN3
        {
            return true
        }
        
        if inputPos != nil
        {
            if state == .After2 || state == .After3
            {
                return true
            }
            else if state == .After1 && inputPos?.colIdx != TableCol.N.rawValue
            {
                return true
            }
        }
        
        
        return inputPos == nil
    }
    
    func confirmInputPos()
    {
        state = .AfterN3
        inputState = .NotAllowed
        updateNajavaValue()
        diceHeld.removeAll()
        if shouldEnd()
        {
            end()
        }
    }
    
    func end()
    {
        state = .EndGame
        print("kraj")
        
        let totalScore = table.totalScore()
        
        // if this is the last player in online match
        if Match.shared.matchType == .OnlineMultiplayer &&  Match.shared.players.count > 1 && Match.shared.indexOfPlayerOnTurn != 0
        {
            WsAPI.shared.turn(.End, matchId: Match.shared.id, params: JSON([:]))
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.multiplayerMatchEnded, object: Match.shared.id)
        }
        else if Match.shared.matchType == .SinglePlayer
        {
            let statItem = StatItem(
                playerId: id!,
                matchType: .SinglePlayer,
                diceNum: Match.shared.diceNum,
                score: totalScore ?? 0,
                result: .Drawn,
                bet: 0,
                timestamp: NSDate())
            
            PlayerStat.shared.items.append(statItem)
            ServerAPI.statItem(statItem.json(), completionHandler: { (data, response, error) in
                print(response)
            })
        }
        
        // score submit for local player only
        if id == PlayerStat.shared.id
        {
            if GameKitHelper.shared.authenticated
            {
                let score = GKScore(leaderboardIdentifier: Match.shared.diceNum == .Five ? LeaderboardId.dice5 : LeaderboardId.dice6)
                
                if totalScore != nil
                {
                    score.value = Int64(totalScore!)
                    
                    GKScore.reportScores([score]) { (error) in
                        if error == nil
                        {
                            print("score reported")
                        }
                    }
                }
            }            
        }
        
        FIRAnalytics.logEventWithName("game_end", parameters: nil)
    }
    
    func printStatus()
    {
        print(state,rollState,inputState,(inputPos != nil ? "\(inputPos!.colIdx) \(inputPos!.rowIdx)" : ""))
    }
    
    func onDieTouched(dieIdx: UInt)
    {
        if inputState == .Must
        {
            return
        }
        
        if state == .Start || state == .EndGame || state == .After3 || state == .AfterN3 || state == .WaitTurn
        {
            return
        }
        
        if diceHeld.contains(dieIdx)
        {
            diceHeld.remove(dieIdx)
        }
        else
        {
            diceHeld.insert(dieIdx)
        }
        
        if diceHeld.count == Match.shared.diceNum.rawValue && inputPos?.colIdx == TableCol.N.rawValue
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.alertForInput, object: nil)
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
        
        if diceHeld.count == Match.shared.diceNum.rawValue
        {
            return false
        }
        
        if state == .After1 && inputPos == nil
        {
            if table.areFulfilled([.Down,.Up,.UpDown])
            {
                return false
            }
        }
        return true
    }

}
