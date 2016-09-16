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

enum GameType
{
    case SinglePlayer
    case LocalMultiplayer
    case OnlineMultiplayer
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
    
    var gameType = GameType.SinglePlayer
    var matchId: UInt = 0
    var players = [Player]()
    var indexOfPlayerOnTurn: Int = 0
    var diceNum = DiceNum.Six
    
    var ctColumns = 6
    
    override init() {
        super.init()
    }
    
    func start(gameType: GameType, playersDesc: [(id: String?,diceMat: DiceMaterial)], matchId: UInt = 0)
    {
        self.gameType = gameType
        self.matchId = matchId
        players.removeAll()
        for (id,diceMat) in playersDesc
        {
            let player = Player()
            player.id = id
            player.diceMaterial = diceMat
            players.append(player)
//            player.table.fakeFill()
            player.printStatus()
        }
        indexOfPlayerOnTurn = 0
        
        DiceScene.shared.start()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
        FIRAnalytics.logEventWithName("game_start", parameters: ["dice_num": diceNum.rawValue])
    }
    
    func nextPlayer()
    {
        if gameType == .OnlineMultiplayer
        {
            sendTurn()
        }
        
        players[indexOfPlayerOnTurn].next()
        indexOfPlayerOnTurn = (indexOfPlayerOnTurn+1)%players.count
        DiceScene.shared.recreateMaterials()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    func player(id: String) -> Player?
    {
        if let idx = players.indexOf({$0.id == id})
        {
            return players[idx]
        }
        return nil
    }
    
    func roll()
    {
        players[indexOfPlayerOnTurn].roll()
    }
    
    
    func didSelectCellAtPos(pos: TablePos)
    {
        let player = players[indexOfPlayerOnTurn]
        player.didSelectCellAtPos(pos)
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
    }
    
    
    
    func onDieTouched(dieIdx: UInt)
    {
        let player = players[indexOfPlayerOnTurn]
        player.onDieTouched(dieIdx)        
    }
    
    func isRollEnabled() -> Bool
    {
        let player = players[indexOfPlayerOnTurn]
        return player.isRollEnabled()
    }
    
    func status() -> String?
    {
        return nil
    }
    
    func sendTurn()
    {
        // ..... hm staro
    }
    
    func isLocalPlayerTurn() -> Bool
    {
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)
        let player = players[indexOfPlayerOnTurn]
        return player.id == playerId
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(players, forKey: keyPlayers)
        aCoder.encodeInteger(indexOfPlayerOnTurn, forKey: keyIdxPlayer)
        aCoder.encodeInteger(diceNum.rawValue, forKey: keyDiceNum)
        
        aCoder.encodeInteger(ctColumns, forKey: keyCtColumns)

    }
    
    required init?(coder aDecoder: NSCoder)
    {
        players = aDecoder.decodeObjectForKey(keyPlayers) as! [Player]
        indexOfPlayerOnTurn = aDecoder.decodeIntegerForKey(keyIdxPlayer)
        diceNum = DiceNum(rawValue: aDecoder.decodeIntegerForKey(keyDiceNum))!
        
        ctColumns = aDecoder.decodeIntegerForKey(keyCtColumns)
        super.init()
    }
}

