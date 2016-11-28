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

enum MatchType: String
{
    case SinglePlayer = "sp"
    case LocalMultiplayer = "lmp"
    case OnlineMultiplayer = "omp"
}

class Match: NSObject, NSCoding
{
    static var shared = Match() {
        didSet {
            print("Game did set")
            DiceScene.shared.updateDiceValues()
            DiceScene.shared.updateDiceSelection()
        }
    }
    
    var matchType = MatchType.SinglePlayer
    var id: UInt = 0
    var players = [Player]()
    var indexOfPlayerOnTurn: Int = 0
    var diceNum = DiceNum.Six
    var bet = 5
    var turnDuration: NSTimeInterval = 60
    var turnId = 0
    
    var ctColumns = 6
    
    override init() {
        super.init()
    }
    
    func start(matchType: MatchType, diceNum: DiceNum, playersDesc: [(id: String?, alias: String?, avgScore6: Float, diceMat: DiceMaterial)], matchId: UInt, bet: Int)
    {
        self.matchType = matchType
        self.diceNum = diceNum
        self.bet = bet
        self.turnDuration = FIRRemoteConfig.remoteConfig()["turn_duration"].numberValue!.doubleValue
        id = matchId
        players.removeAll()
        for (id,alias,avgScore6,diceMat) in playersDesc
        {
            let player = Player()
            player.id = id
            player.alias = alias
            player.avgScore6 = avgScore6
            player.diceMaterial = diceMat
            players.append(player)
            // player.table.fakeFill()
            player.printStatus()
        }
        indexOfPlayerOnTurn = 0
        
        DiceScene.shared.start()
        
        NSUserDefaults.standardUserDefaults().setObject(diceNum == .Five ? LeaderboardId.dice5 : LeaderboardId.dice6, forKey: Prefs.lastPlayedGameType)
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
        FIRAnalytics.logEventWithName("game_start", parameters: ["dice_num": diceNum.rawValue])
    }
    
    func nextPlayer()
    {
        if matchType == .OnlineMultiplayer && isLocalPlayerTurn()
        {
            let params = JSON([:])
            WsAPI.shared.turn(.NextPlayer, matchId: id, params: params)
        }
        
        players[indexOfPlayerOnTurn].next()
        indexOfPlayerOnTurn = (indexOfPlayerOnTurn+1)%players.count
        players[indexOfPlayerOnTurn].onTurn()
        DiceScene.shared.recreateMaterials()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
        
        if matchType == .OnlineMultiplayer
        {
            // start the expiration timer
            turnId += 1
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.onPlayerTurnInMultiplayer, object: turnId)
        }
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
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
        
    
    func isLocalPlayerTurn() -> Bool
    {
        let playerId = PlayerStat.shared.id
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

