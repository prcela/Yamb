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
        socket = WebSocket(url: NSURL(string: "ws://192.168.5.10:8080/chat/")!)
        socket.headers["Sec-WebSocket-Protocol"] = "no-body"
        socket.delegate = self
        socket.connect()
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
            let players = json["players"].arrayValue
            Room.main.players.removeAll()
            for p in players
            {
                let id = p["id"].stringValue
                let alias = p["alias"].stringValue
                Room.main.players.append((id: id, alias: alias))
            }
            
        default:
            break
        }
    }
}


