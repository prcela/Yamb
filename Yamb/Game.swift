//
//  Game.swift
//  Yamb
//
//  Created by prcela on 16/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import Firebase
import GameKit

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
    case NextPlayer
    case End
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
    
    var players = [Player]()
    var idxPlayer: Int = 0
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
    
    var inputPos: TablePos?
    
    var ctColumns = 6
    
    func start(playerIds: [String?])
    {
        state = .Start
        rollState = .NotRolling
        inputState = .NotAllowed
        inputPos = nil
        diceValues = nil
        diceHeld.removeAll()
        players.removeAll()
        for playerId in playerIds
        {
            let player = Player()
            player.id = playerId
            players.append(player)
//            player.table.fakeFill()
        }
        idxPlayer = 0
        
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        printStatus()
        FIRAnalytics.logEventWithName("game_start", parameters: ["dice_num": diceNum.rawValue])
    }
    
    func nextPlayer()
    {
        state = .NextPlayer
        idxPlayer = (idxPlayer+1)%players.count
        inputPos = nil
        diceHeld.removeAll()
        inputState = .NotAllowed
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
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
                case .After1, .After2, .After3, .AfterN3, .NextPlayer:
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
        
        if state == .End
        {
            start(players.map({ $0.id }))
            return
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
        case .Start, .NextPlayer:
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
            
        case .End:
            break
        }
        
        printStatus()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func updateNajavaValue()
    {
        let player = players[idxPlayer]
        
        if let pos = inputPos
        {
            player.table.updateValue(pos, diceValues: diceValues)
            player.table.recalculateSumsForColumn(pos.colIdx, diceValues: diceValues)
            if player.table.isQualityValueFor(pos, diceValues: diceValues)
            {
                state = .AfterN3
                inputState = .NotAllowed
                diceHeld.removeAll()
            }
        }
    }
    
    func didSelectCellAtPos(pos: TablePos)
    {
        let player = players[idxPlayer]
        
        var oldValue: UInt?
        if let clearPos = inputPos
        {
            oldValue = player.table.values[clearPos.colIdx][clearPos.rowIdx]
            player.table.values[clearPos.colIdx][clearPos.rowIdx] = nil
            player.table.recalculateSumsForColumn(clearPos.colIdx, diceValues: diceValues)
        }
        
        if pos != inputPos
        {
            inputPos = pos
            player.table.updateValue(pos, diceValues: diceValues)
        }
        else if oldValue == nil
        {
            player.table.updateValue(pos, diceValues: diceValues)
        }
        else
        {
            // obrisana stara vrijednost
            inputPos = nil
        }
        
        player.table.recalculateSumsForColumn(pos.colIdx, diceValues: diceValues)
                
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
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
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
        
        if state == .Start || state == .End || state == .After3 || state == .AfterN3 || state == .NextPlayer
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
        
        if diceHeld.count == diceNum.rawValue && inputPos?.colIdx == TableCol.N.rawValue
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.alertForInput, object: nil)
        }
    }
    
    func isRollEnabled() -> Bool
    {
        let player = players[idxPlayer]
        
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
        
        if state == .After1 && inputPos == nil
        {
            if player.table.areFulfilled([.Down,.Up,.UpDown])
            {
                return false
            }
        }
        return true
    }
    
    func shouldEnd() -> Bool
    {
        let player = players[idxPlayer]
        if !player.table.areFulfilled([.Down, .Up, .UpDown, .N])
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
        

        return false
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
    
    func status() -> String?
    {
        return nil
    }
    
    func end()
    {
        state = .End
        print("kraj")
        
        // score submit
        if GameKitHelper.shared.authenticated
        {
            let player = players[idxPlayer]
            let score = GKScore(leaderboardIdentifier: Game.shared.diceNum == .Five ? LeaderboardId.dice5 : LeaderboardId.dice6)
            
            if let totalScore = player.table.totalScore()
            {
                score.value = Int64(totalScore)
                
                GKScore.reportScores([score]) { (error) in
                    if error == nil
                    {
                        print("score reported")
                    }
                }
            }
        }
        
        FIRAnalytics.logEventWithName("game_end", parameters: nil)
    }
    
    
}