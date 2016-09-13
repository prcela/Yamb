//
//  WsAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit

class WsAPI
{
    static let shared = WsAPI()
    
    var socket: WebSocket
    
    init() {
        let ipHome = "192.168.5.10"
        let ipServer = "139.59.142.160"
        let strURL = "ws://\(ipHome):8080/chat/"
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
        let json = JSON(["msg_func":"join","id":playerId,"alias":playerAlias])
        let data = try! json.rawData()
        socket.writeData(data)
    }
    
    func roomInfo()
    {
        let json = JSON(["msg_func":"room_info"])
        let data = try! json.rawData()
        socket.writeData(data)
    }
    
    func createMatch()
    {
        let json = JSON(["msg_func":"create_match"])
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
            print("joined")
            roomInfo()
        
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
            roomInfo()
            
        default:
            break
        }
    }
}


