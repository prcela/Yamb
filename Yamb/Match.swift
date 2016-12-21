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
import Crashlytics
import SwiftyJSON

private let keyPlayers = "keyPlayers"
private let keyIdxPlayer = "keyIdxPlayer"
private let keyDiceNum = "keyDiceNum"
private let keyCtColumns = "keyCtColumns"

enum DiceNum: Int
{
    case five = 5
    case six = 6
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
            let player = shared.players[shared.indexOfPlayerOnTurn]
            if let values = player.diceValues
            {
                let diceScene = PlayViewController.diceScene
                diceScene.updateDiceValues(values)
                diceScene.updateDiceSelection(player.diceHeld)
            }
            
        }
    }
    
    var matchType = MatchType.SinglePlayer
    var id: UInt = 0
    var players = [Player]()
    var indexOfPlayerOnTurn: Int = 0
    var diceNum = DiceNum.six
    var bet = 5
    var turnDuration: TimeInterval = 60
    var turnId = 0
    
    var ctColumns = 6
    
    override init() {
        super.init()
    }
    
    func start(_ matchType: MatchType, diceNum: DiceNum, playersDesc: [(id: String?, alias: String?, avgScore6: Float, diceMat: DiceMaterial)], matchId: UInt, bet: Int)
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
        
        let diceScene = PlayViewController.diceScene
        diceScene.start(diceNum.rawValue)
        diceScene.updateDiceSelection(players.first!.diceHeld)
        
        UserDefaults.standard.set(diceNum == .five ? LeaderboardId.dice5 : LeaderboardId.dice6, forKey: Prefs.lastPlayedGameType)
        
        NotificationCenter.default.post(name: NotificationName.matchStateChanged, object: nil)
        
        Answers.logLevelStart(matchType.rawValue, customAttributes: ["diceNum" : diceNum.rawValue])
        
        FIRAnalytics.logEvent(withName: "game_start", parameters: ["dice_num": diceNum.rawValue as NSObject])
    }
    
    func nextPlayer()
    {
        if matchType == .OnlineMultiplayer && isLocalPlayerTurn()
        {
            let params = JSON([:])
            WsAPI.shared.turn(.nextPlayer, matchId: id, params: params)
        }
        
        players[indexOfPlayerOnTurn].next()
        indexOfPlayerOnTurn = (indexOfPlayerOnTurn+1)%players.count
        
        let player = players[indexOfPlayerOnTurn]
        player.onTurn()
        
        let diceScene = PlayViewController.diceScene
        diceScene.recreateMaterials(player.diceMaterial)
        if let values = player.diceValues
        {
            diceScene.updateDiceValues(values)
        }
        
        NotificationCenter.default.post(name: NotificationName.matchStateChanged, object: nil)
        print("Next player on turn: \(indexOfPlayerOnTurn)")
        
        if matchType == .OnlineMultiplayer
        {
            // start the expiration timer
            turnId += 1
            NotificationCenter.default.post(name: NotificationName.onPlayerTurnInMultiplayer, object: turnId)
        }
    }
    
    func player(_ id: String) -> Player?
    {
        if let idx = players.index(where: {$0.id == id})
        {
            return players[idx]
        }
        return nil
    }
    
    func roll()
    {
        players[indexOfPlayerOnTurn].roll()
    }
    
    
    func didSelectCellAtPos(_ pos: TablePos)
    {
        let player = players[indexOfPlayerOnTurn]
        player.didSelectCellAtPos(pos)
        
        NotificationCenter.default.post(name: NotificationName.matchStateChanged, object: nil)
    }
    
    
    
    func onDieTouched(_ dieIdx: UInt)
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
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(players, forKey: keyPlayers)
        aCoder.encode(indexOfPlayerOnTurn, forKey: keyIdxPlayer)
        aCoder.encode(diceNum.rawValue, forKey: keyDiceNum)
        
        aCoder.encode(ctColumns, forKey: keyCtColumns)

    }
    
    required init?(coder aDecoder: NSCoder)
    {
        players = aDecoder.decodeObject(forKey: keyPlayers) as! [Player]
        indexOfPlayerOnTurn = aDecoder.decodeInteger(forKey: keyIdxPlayer)
        diceNum = DiceNum(rawValue: aDecoder.decodeInteger(forKey: keyDiceNum))!
        
        ctColumns = aDecoder.decodeInteger(forKey: keyCtColumns)
        super.init()
    }
}

