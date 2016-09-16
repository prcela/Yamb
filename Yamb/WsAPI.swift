//
//  WsAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit

private let ipHome = "192.168.5.10"
private let ipWork = "10.0.21.221"
private let ipServer = "139.59.142.160"

class WsAPI
{
    static let shared = WsAPI()
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipWork):8080/chat/"
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
        print("Sending:\n\(json)")
        let data = try! json.rawData()
        socket.writeData(data)
    }
}

extension WsAPI: WebSocketDelegate
{
    func websocketDidConnect(socket: WebSocket) {
        print("didConnect")
        
        joinToRoom()
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocketDidDisconnect")
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
            
        case .Turn:
            let matchId = json["match_id"].uIntValue
            guard matchId == Game.shared.matchId else {
                return
            }
            let params = json["params"]
            let turn = Turn(rawValue: json["turn"].stringValue)!
            switch turn
            {
            case .RollDice:
                let values = params.arrayObject as! [UInt]
                DiceScene.shared.rollToValues(values, ctMaxRounds: 3, completion: {})
                
            case .HoldDice:
                let holdDice = params.arrayObject as! [UInt]
                let playerId = json["id"].stringValue
                guard let player = Game.shared.player(playerId) else {return}
                player.diceHeld = Set(holdDice)
                
            case .End:
                Game.shared.nextPlayer()
                
            default:
                break
            }
            
        default:
            break
        }
    }
}


