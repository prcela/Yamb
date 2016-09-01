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

private let keyPlayers = "keyPlayers"
private let keyIdxPlayer = "keyIdxPlayer"
private let keyDiceNum = "keyDiceNum"
private let keyCtColumns = "keyCtColumns"

enum DiceNum: Int
{
    case Five = 5
    case Six = 6
}


class Game: NSObject, NSCoding
{
    static var shared = Game() {
        didSet {
            print("Game did set")
            DiceScene.shared.updateDiceValues()
            DiceScene.shared.updateDiceSelection()
        }
    }
    
    var players = [Player]()
    var idxPlayer: Int = 0
    var diceNum = DiceNum.Six
    
    var ctColumns = 6
    
    override init() {
        super.init()
    }
    
    func start(playerIds: [String?])
    {
        players.removeAll()
        for playerId in playerIds
        {
            let player = Player()
            player.id = playerId
            players.append(player)
//            player.table.fakeFill()
            player.printStatus()
        }
        idxPlayer = 0
        
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        FIRAnalytics.logEventWithName("game_start", parameters: ["dice_num": diceNum.rawValue])
    }
    
    func nextPlayer()
    {
        players[idxPlayer].next()
        idxPlayer = (idxPlayer+1)%players.count
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func roll()
    {
        players[idxPlayer].roll()
    }
    
    
    func didSelectCellAtPos(pos: TablePos)
    {
        let player = players[idxPlayer]
        player.didSelectCellAtPos(pos)
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    
    
    func onDieTouched(dieIdx: UInt)
    {
        let player = players[idxPlayer]
        player.onDieTouched(dieIdx)        
    }
    
    func isRollEnabled() -> Bool
    {
        let player = players[idxPlayer]
        return player.isRollEnabled()
    }
    
    func status() -> String?
    {
        return nil
    }
    
    
    
    
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(players, forKey: keyPlayers)
        aCoder.encodeInteger(idxPlayer, forKey: keyIdxPlayer)
        aCoder.encodeInteger(diceNum.rawValue, forKey: keyDiceNum)
        
        aCoder.encodeInteger(ctColumns, forKey: keyCtColumns)

    }
    
    required init?(coder aDecoder: NSCoder)
    {
        players = aDecoder.decodeObjectForKey(keyPlayers) as! [Player]
        idxPlayer = aDecoder.decodeIntegerForKey(keyIdxPlayer)
        diceNum = DiceNum(rawValue: aDecoder.decodeIntegerForKey(keyDiceNum))!
        
        ctColumns = aDecoder.decodeIntegerForKey(keyCtColumns)
        super.init()
    }
}

