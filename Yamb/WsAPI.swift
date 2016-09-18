//
//  WsAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit

private let ipHome = "192.168.5.10:8080"
private let ipWork = "10.0.21.221:8080"
private let ipServer = "139.59.142.160:80"

class WsAPI
{
    static let shared = WsAPI()
    private var retryCount = 0
    private var unsentMessages = [NSData]()
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipHome)/chat/"
        socket = WebSocket(url: NSURL(string: strURL)!)
        socket.headers["Sec-WebSocket-Protocol"] = "no-body"
        socket.delegate = self
    }
    
    func connect()
    {
        socket.connect()
    }
    
    func joinToRoom()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let playerId = defaults.stringForKey(Prefs.playerId)!
        let playerAlias = defaults.stringForKey(Prefs.playerAlias)!
        let json = JSON(["id":playerId,"alias":playerAlias])
        send(.Join, json:json)
    }
    
    func roomInfo()
    {
        send(.RoomInfo)
    }
    
    func createMatch()
    {
        send(.CreateMatch)
    }
    
    func joinToMatch(matchId: UInt)
    {
        let json = JSON(["match_id":matchId])
        send(.JoinMatch, json: json)
    }
    
    func leaveMatch(matchId: UInt)
    {
        let json = JSON(["match_id":matchId])
        send(.LeaveMatch, json: json)
    }
    
    func turn(turn: Turn, matchId: UInt, params: JSON)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let playerId = defaults.stringForKey(Prefs.playerId)!
        var json = JSON(["match_id":matchId,"turn":turn.rawValue])
        json["params"] = params
        json["id"].string = playerId
        send(.Turn, json: json)
    }
    
    private func send(action: MessageFunc, json: JSON? = nil)
    {
        var json = json ?? JSON([:])
        json["msg_func"].string = action.rawValue
        
        let data = try! json.rawData()
        
        if socket.isConnected
        {
            print("Sending:\n\(json)")
            socket.writeData(data)
        }
        else
        {
            print("Keeping:\n\(json)")
            unsentMessages.append(data)
        }
    }
    
    private func sendUnsentMessages()
    {
        guard socket.isConnected else {
            return
        }
        for data in unsentMessages
        {
            socket.writeData(data)
        }
        unsentMessages.removeAll()
    }
}

extension WsAPI: WebSocketDelegate
{
    func websocketDidConnect(socket: WebSocket) {
        print("didConnect to \(socket.currentURL)")
        retryCount = 0
        joinToRoom()
        sendUnsentMessages()
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocketDidDisconnect")
        
        dispatchToMainQueue(delay: min(Double(retryCount), 5)) {
            print("retry connect")
            self.connect()
            self.retryCount += 1
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("websocketDidReceiveMessage: \(text)")
        
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {return}
        let json = JSON(data: data)
        
        switch MessageFunc(rawValue: json["msg_func"].stringValue)!
        {
        
        case .Join:
            print("some player joined")
            
        case .Disjoin:
            print("someone disjoined")
        
        case .RoomInfo:
            
            Room.main.freePlayers.removeAll()
            Room.main.matches.removeAll()
            
            let freePlayers = json["free_players"].arrayValue
            for p in freePlayers
            {
                let player = Player()
                player.id = p["id"].stringValue
                player.alias = p["alias"].stringValue
                Room.main.freePlayers.append(player)
            }
            
            let matches = json["matches"].arrayValue
            for m in matches
            {
                let match = Match()
                match.id = m["id"].uIntValue
                match.state = MatchState(rawValue: m["state"].stringValue)!
                
                let players = m["players"].arrayValue
                for p in players
                {
                    let player = Player()
                    player.id = p["id"].stringValue
                    player.alias = p["alias"].stringValue
                    match.players.append(player)
                }
                Room.main.matches.append(match)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.onRoomInfo, object: nil)
            
        case .CreateMatch:
            print("Match created")
            
        case .JoinMatch:
            let matchId = json["match_id"].uIntValue
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.joinedMatch, object: matchId)
            
        case .LeaveMatch:
            let matchId = json["match_id"].uIntValue
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.opponentLeavedMatch, object: matchId)
            break
            
        case .Turn:
            let matchId = json["match_id"].uIntValue
            guard matchId == Game.shared.matchId else {
                return
            }
            let params = json["params"]
            let turn = Turn(rawValue: json["turn"].intValue)!
            switch turn
            {
            case .RollDice:
                let playerId = json["id"].stringValue
                let values = params["values"].arrayObject as! [UInt]
                let rounds = params["rounds"].arrayObject as! [[Int]]
                guard let player = Game.shared.player(playerId) else {return}
                player.activeRotationRounds = rounds
                DiceScene.shared.rollToValues(values, ctMaxRounds: 3, completion: {})
                
            case .HoldDice:
                let holdDice = params.arrayObject as! [UInt]
                let playerId = json["id"].stringValue
                guard let player = Game.shared.player(playerId) else {return}
                player.diceHeld = Set(holdDice)
                
            case .End:
                Game.shared.nextPlayer()
                
            case .SetValueAtTablePos:
                let playerId = json["id"].stringValue
                let posColIdx = params["posColIdx"].intValue
                let posRowIdx = params["posRowIdx"].intValue
                let value = params["value"].uInt
                guard let player = Game.shared.player(playerId) else {return}
                player.table.values[posColIdx][posRowIdx] = value
                
            case .InputPos:
                let playerId = json["id"].stringValue
                guard let player = Game.shared.player(playerId) else {return}
                if params.dictionary!.isEmpty
                {
                    player.inputPos = nil
                }
                else
                {
                    let colIdx = params["colIdx"].intValue
                    let rowIdx = params["rowIdx"].intValue
                    player.inputPos = TablePos(rowIdx: rowIdx, colIdx: colIdx)
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.gameStateChanged, object: nil)
            
        default:
            break
        }
    }
}


