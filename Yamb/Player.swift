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
import Crashlytics
import SwiftyJSON

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
    case start = 0
    case after1
    case after2
    case after3
    case afterN2
    case afterN3
    case waitTurn
    case endGame
}



enum RollState: Int {
    case rolling = 0
    case notRolling
}


enum InputState: Int
{
    case notAllowed = 0
    case allowed
    case must
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
    var inputState = InputState.notAllowed
    var state = PlayerState.start
    var rollState = RollState.notRolling
    var diceValues: [UInt]?
    var diceHeld = Set<UInt>() {
        didSet {
            PlayViewController.diceScene.updateDiceSelection(diceHeld)
            NotificationCenter.default.post(name: .matchStateChanged, object: nil)
            
            if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
            {
                let params = JSON(Array(diceHeld))
                WsAPI.shared.turn(.holdDice, matchId: Match.shared.id, params: params)
            }
        }
    }
    var activeRotationRounds = [[Int]](repeating: [0,0,0], count: 6)
    
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
                WsAPI.shared.turn(.inputPos, matchId: Match.shared.id, params: params)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: keyId) as? String
        table = aDecoder.decodeObject(forKey: keyTable) as! Table
        inputState = InputState(rawValue: aDecoder.decodeInteger(forKey: keyInputState))!
        state = PlayerState(rawValue: aDecoder.decodeInteger(forKey: keyState))!
        rollState = RollState(rawValue: aDecoder.decodeInteger(forKey: keyRollState))!
        diceValues = aDecoder.decodeObject(forKey: keyDiceValues) as? [UInt]
        diceHeld = (aDecoder.decodeObject(forKey: keyDiceHeld) as? Set<UInt>)!
        
        if aDecoder.containsValue(forKey: keyInputPosRow)
        {
            let row = aDecoder.decodeInteger(forKey: keyInputPosRow)
            let col = aDecoder.decodeInteger(forKey: keyInputPosCol)
            inputPos = TablePos(rowIdx: row, colIdx: col)
        }
        diceMaterial = DiceMaterial(rawValue: aDecoder.decodeObject(forKey: keyDiceMaterial) as? String ?? "a")!

        super.init()
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(id, forKey: keyId)
        aCoder.encode(table, forKey: keyTable)
        aCoder.encode(inputState.rawValue, forKey: keyInputState)
        aCoder.encode(state.rawValue, forKey: keyState)
        aCoder.encode(rollState.rawValue, forKey: keyRollState)
        aCoder.encode(diceValues, forKey: keyDiceValues)
        aCoder.encode(diceHeld, forKey: keyDiceHeld)
        
        if let pos = inputPos
        {
            aCoder.encode(pos.rowIdx, forKey: keyInputPosRow)
            aCoder.encode(pos.colIdx, forKey: keyInputPosCol)
        }
        aCoder.encode(diceMaterial.rawValue, forKey: keyDiceMaterial)

    }
    
    func next()
    {
        state = .waitTurn
        inputPos = nil
        diceHeld.removeAll()
        inputState = .notAllowed
    }
    
    func onTurn()
    {
        inputPos = nil
        diceHeld.removeAll()
        inputState = .notAllowed
    }
    
    func roll()
    {
        guard !(inputState == .must && inputPos == nil) else {return}
        
        if inputPos != nil
        {
            if inputPos!.colIdx != TableCol.n.rawValue
            {
                switch state
                {
                case .after1, .after2, .after3, .afterN3, .waitTurn:
                    state = .start
                    diceHeld.removeAll()
                    inputPos = nil
                default:
                    break
                }
            }
            
            if state == .afterN3 || state == .after3
            {
                diceHeld.removeAll()
                inputPos = nil
            }
        }
        
        rollState = .rolling
        NotificationCenter.default.post(name: .matchStateChanged, object: nil)
        
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
            
            
            for (idx,_) in newRounds.enumerated()
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
            WsAPI.shared.turn(.rollDice, matchId: Match.shared.id, params: params)
        }
        
        PlayViewController.diceScene.rollToValues(values, ctMaxRounds: ctMaxRounds, activeRotationRounds: activeRotationRounds, ctHeld: diceHeld.count) {
            self.rollState = .notRolling
            self.diceValues = values
            self.afterRoll()
        }
    }
    
    func afterRoll()
    {
        switch state
        {
        case .start, .waitTurn:
            state = .after1
            inputState = .allowed
            inputPos = nil
            
        case .after1:
            if inputPos == nil
            {
                state = .after2
                inputState = .allowed
            }
            else if inputPos!.colIdx == TableCol.n.rawValue
            {
                state = .afterN2
                inputState = .notAllowed
                updateNajavaValue()
            }
            
        case .after2:
            if inputPos == nil
            {
                state = .after3
                inputState = .must
                diceHeld.removeAll()
            }
            else
            {
                state = .after1
                inputState = .allowed
                inputPos = nil
            }
            
        case .after3:
            state = .after1
            inputState = .allowed
            inputPos = nil
            diceHeld.removeAll()
            
        case .afterN2:
            state = .afterN3
            inputState = .notAllowed
            updateNajavaValue()
            diceHeld.removeAll()
            if shouldEnd()
            {
                end()
            }
            
        case .afterN3:
            updateNajavaValue()
            state = .after1
            inputState = .allowed
            inputPos = nil
            diceHeld.removeAll()
            
        case .endGame:
            break
        }
        
        printStatus()
        NotificationCenter.default.post(name: .matchStateChanged, object: nil)
    }
    
    func updateNajavaValue()
    {
        if let pos = inputPos
        {
            let _ = table.updateValue(atPos: pos, diceValues: diceValues)
            table.recalculateSums(atCol: pos.colIdx, diceValues: diceValues)
            if table.isQualityValueFor(pos, diceValues: diceValues)
            {
                state = .afterN3
                inputState = .notAllowed
                diceHeld.removeAll()
            }
        }
    }
    
    func didSelectCellAtPos(_ pos: TablePos)
    {
        var oldValue: UInt?
        if let oldPos = inputPos
        {
            oldValue = table.values[oldPos.colIdx][oldPos.rowIdx]
            if state == .afterN2
            {
                state = .afterN3
            }
            else
            {
                table.values[oldPos.colIdx][oldPos.rowIdx] = nil
                table.recalculateSums(atCol: oldPos.colIdx, diceValues: diceValues)
                
                if Match.shared.matchType == .OnlineMultiplayer && Match.shared.isLocalPlayerTurn()
                {
                    var params = JSON(["posColIdx":oldPos.colIdx, "posRowIdx":oldPos.rowIdx])
                    params["value"].uInt = nil
                    WsAPI.shared.turn(.setValueAtTablePos, matchId: Match.shared.id, params: params)
                }
            }
        }
        
        if pos != inputPos
        {
            inputPos = pos
            let _ = table.updateValue(atPos: pos, diceValues: diceValues)
        }
        else if oldValue == nil
        {
            let _ = table.updateValue(atPos: pos, diceValues: diceValues)
        }
        else
        {
            // obrisana stara vrijednost
            inputPos = nil
        }
        
        table.recalculateSums(atCol: pos.colIdx, diceValues: diceValues)
        
        if state == .after3 || state == .afterN3
        {
            diceHeld.removeAll()
        }
        
        if pos.colIdx == TableCol.n.rawValue
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
    
    func forceAnyTurn()
    {
        let _ = table.fillAnyEmptyPos()
    }
    
    func shouldEnd() -> Bool
    {
        if state == .endGame
        {
            // already finished
            return false
        }
        
        if !table.areFulfilled([.down, .up, .upDown, .n])
        {
            return false
        }
        
        if state == .afterN3
        {
            return true
        }
        
        if inputPos != nil
        {
            if state == .after2 || state == .after3
            {
                return true
            }
            else if state == .after1 && inputPos?.colIdx != TableCol.n.rawValue
            {
                return true
            }
        }
        
        
        return inputPos == nil
    }
    
    func confirmInputPos()
    {
        state = .afterN3
        inputState = .notAllowed
        updateNajavaValue()
        diceHeld.removeAll()
        if shouldEnd()
        {
            end()
        }
    }
    
    func end()
    {
        state = .endGame
        print("kraj")
        
        let totalScore = table.totalScore()
        
        // if this is the last player in online match
        if Match.shared.matchType == .OnlineMultiplayer &&  Match.shared.players.count > 1 && Match.shared.indexOfPlayerOnTurn != 0
        {
            WsAPI.shared.turn(.end, matchId: Match.shared.id, params: JSON([:]))
            NotificationCenter.default.post(name: .multiplayerMatchEnded, object: Match.shared.id)
            Answers.logLevelEnd(Match.shared.matchType.rawValue, score: nil, success: nil, customAttributes: ["diceNum":Match.shared.diceNum.rawValue])
        }
        else if Match.shared.matchType == .SinglePlayer
        {
            let statItem = StatItem(
                playerId: id!,
                matchType: .SinglePlayer,
                diceNum: Match.shared.diceNum,
                score: totalScore ?? 0,
                result: .drawn,
                bet: 0,
                timestamp: Date())
            
            PlayerStat.shared.items.append(statItem)
            ServerAPI.statItem(statItem.json(), completionHandler: { (data, response, error) in
                print(response ?? "invalid respose")
            })
            Answers.logLevelEnd(statItem.matchType.rawValue,
                                score: NSNumber(value: statItem.score),
                                success: nil,
                                customAttributes: ["diceNum":statItem.diceNum.rawValue])
        }
        
        // score submit for local player only
        if id == PlayerStat.shared.id
        {
            if GameKitHelper.shared.authenticated
            {
                let score = GKScore(leaderboardIdentifier: Match.shared.diceNum == .five ? LeaderboardId.dice5 : LeaderboardId.dice6)
                
                if totalScore != nil
                {
                    score.value = Int64(totalScore!)
                    
                    GKScore.report([score], withCompletionHandler: { (error) in
                        if error == nil
                        {
                            print("score reported")
                        }
                    }) 
                }
            }            
        }
        
        FIRAnalytics.logEvent(withName: "game_end", parameters: nil)
    }
    
    func printStatus()
    {
        print(state,rollState,inputState,(inputPos != nil ? "\(inputPos!.colIdx) \(inputPos!.rowIdx)" : ""))
    }
    
    func onDieTouched(_ dieIdx: UInt)
    {
        if inputState == .must
        {
            return
        }
        
        if state == .start || state == .endGame || state == .after3 || state == .afterN3 || state == .waitTurn
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
        
        if diceHeld.count == Match.shared.diceNum.rawValue && inputPos?.colIdx == TableCol.n.rawValue
        {
            NotificationCenter.default.post(name: .alertForInput, object: nil)
        }
    }
    
    func isRollEnabled() -> Bool
    {
        if inputState == .must && inputPos == nil
        {
            return false
        }
        
        if rollState == .rolling
        {
            return false
        }
        
        if diceHeld.count == Match.shared.diceNum.rawValue
        {
            return false
        }
        
        if state == .after1 && inputPos == nil
        {
            if table.areFulfilled([.down,.up,.upDown])
            {
                return false
            }
        }
        return true
    }

}
