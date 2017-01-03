//
//  WsAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit
import Starscream
import SwiftyJSON

private let ipHome = "192.168.5.11:8181"
private let ipWork = "10.0.21.221:8181"
private let ipServer = "139.59.142.160:80"
let ipCurrent = ipServer

class WsAPI
{
    static let shared = WsAPI()
    fileprivate var retryCount = 0
    fileprivate var lastReceivedMsgId: Int?
    fileprivate var unsentMessages = [String]()
    fileprivate var pingInterval: TimeInterval = 30
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipCurrent)/chat/"
        socket = WebSocket(url: URL(string: strURL)!)
        socket.headers["Sec-WebSocket-Protocol"] = "no-body"
        socket.delegate = self
        
        dispatchToMainQueue(delay: pingInterval) { 
            self.ping()
        }
    }
    
    func connect()
    {
        socket.connect()
        NotificationCenter.default.post(name: .wsConnect, object: nil)
    }
    
    func ping()
    {
        print("ping")
        socket.write(ping:Data())
        dispatchToMainQueue(delay: pingInterval) {
            self.ping()
        }
    }
    
    func joinToRoom()
    {
        let playerId = PlayerStat.shared.id
        let playerAlias = PlayerStat.shared.alias
        let avgScore6 = PlayerStat.avgScore(.six)
        let diamonds = PlayerStat.shared.diamonds
        let json = JSON(["id":playerId,"alias":playerAlias,"avg_score_6":avgScore6,"diamonds":diamonds])
        send(.Join, json:json)
    }
    
    func roomInfo()
    {
        send(.RoomInfo)
    }
    
    func createMatch(_ diceNum: DiceNum, isPrivate: Bool, diceMaterials: [DiceMaterial], bet: Int)
    {
        let json = JSON([
            "dice_num":diceNum.rawValue,
            "bet":bet,
            "private":isPrivate,
            "dice_materials": diceMaterials.map({ (dm) -> String in
            return dm.rawValue
        })])
        send(.CreateMatch, json: json)
    }
    
    func joinToMatch(_ matchId: UInt, ownDiceMat: DiceMaterial)
    {
        let json = JSON(["match_id":matchId, "dice_mat":ownDiceMat.rawValue])
        send(.JoinMatch, json: json)
    }
    
    func leaveMatch(_ matchId: UInt)
    {
        let json = JSON(["match_id":matchId])
        send(.LeaveMatch, json: json)
    }
    
    func turn(_ turn: Turn, matchId: UInt, params: JSON)
    {
        let playerId = PlayerStat.shared.id
        var json = JSON(["match_id":matchId,"turn":turn.rawValue])
        json["params"] = params
        json["id"].string = playerId
        send(.Turn, json: json)
    }
    
    func invitePlayer(_ player: Player)
    {
        let playerId = PlayerStat.shared.id
        let json = JSON(["sender":playerId, "recipient":player.id!])
        send(.InvitePlayer, json: json)
        
        // TODO: Show invited popup ...
    }
    
    func ignoreInvitation(_ senderPlayerId: String)
    {
        let playerId = PlayerStat.shared.id
        let json = JSON(["recipient":playerId, "sender":senderPlayerId])
        send(.IgnoreInvitation, json: json)
    }
    
    func sendTextMessage(_ recipient: Player, text: String)
    {
        let playerId = PlayerStat.shared.id
        let json = JSON(["sender":playerId, "recipient":recipient.id!, "text": text])
        send(.TextMessage, json: json)
    }
    
    
    fileprivate func send(_ action: MessageFunc, json: JSON? = nil)
    {
        var json = json ?? JSON([:])
        json["msg_func"].string = action.rawValue
        
        if let text = json.rawString(String.Encoding.utf8, options: [])
        {
            if socket.isConnected
            {
                print("Sending:\n\(text)")
                socket.write(string:text)
            }
            else
            {
                print("Keeping:\n\(text)")
                unsentMessages.append(text)
            }
        }
    }
    
    fileprivate func sendUnsentMessages()
    {
        guard socket.isConnected else {
            return
        }
        for text in unsentMessages
        {
            socket.write(string:text)
        }
        unsentMessages.removeAll()
    }
}

extension WsAPI: WebSocketDelegate
{
    func websocketDidConnect(socket: WebSocket) {
        print("didConnect to \(socket.currentURL)")
        NotificationCenter.default.post(name: .wsDidConnect, object: nil)
        retryCount = 0
        lastReceivedMsgId = nil
        joinToRoom()
        sendUnsentMessages()
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocketDidDisconnect")
        NotificationCenter.default.post(name: .wsDidDisconnect, object: nil)
        
        dispatchToMainQueue(delay: min(Double(retryCount), 5)) {
            print("retry connect")
            self.connect()
            self.retryCount += 1
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("websocketDidReceiveMessage: \(text)")
        
        let json = JSON.parse(text)
        
        // if should acknowledge receiving
        if let msgId = json["msg_id"].int
        {
            socket.write(string: JSON(["ack":msgId]).rawString()!)
            
            if lastReceivedMsgId != nil && msgId <= lastReceivedMsgId!
            {
                // we already process this
                return
            }
            
            lastReceivedMsgId = msgId
        }
        
        guard let msgFunc = MessageFunc(rawValue: json["msg_func"].stringValue) else {
            return
        }
        
        let nc = NotificationCenter.default
        
        switch msgFunc
        {
        
        case .Join:
            print("some player joined")
            
        case .MaybeSomeoneWillDump:
            print("someone will be dumped")
            let matchId = json["match_id"].uIntValue
            guard matchId == Match.shared.id else {
                return
            }
            nc.post(name: .maybeSomeoneWillDump, object: json["id"].stringValue)
            
        case .Dump:
            print("someone dumped")
            let matchId = json["match_id"].uIntValue
            guard matchId == Match.shared.id else {
                return
            }
            nc.post(name: .dumped, object: json["id"].stringValue)
        
        case .RoomInfo:
            
            Room.main.players.removeAll()
            Room.main.matchesInfo.removeAll()
            
            let players = json["players"].arrayValue
            for p in players
            {
                let player = Player()
                player.id = p["id"].stringValue
                player.alias = p["alias"].stringValue
                player.avgScore6 = p["avg_score_6"].floatValue
                player.diamonds = p["diamonds"].intValue
                player.connected = p["connected"].boolValue
                Room.main.players.append(player)
            }
            
            let matches = json["matches"].arrayValue
            for m in matches
            {
                let matchInfo = MatchInfo()
                matchInfo.id = m["id"].uIntValue
                matchInfo.bet = m["bet"].int ?? 0
                matchInfo.isPrivate = m["private"].bool ?? false
                matchInfo.state = MatchState(rawValue: m["state"].stringValue)!
                matchInfo.playerIds = m["players"].arrayObject as! [String]
                matchInfo.diceNum = m["dice_num"].intValue
                matchInfo.diceMaterials = m["dice_materials"].arrayObject as! [String]
                Room.main.matchesInfo.append(matchInfo)
            }
            
            nc.post(name: .onRoomInfo, object: nil)
            
        case .CreateMatch:
            print("Match created")
            
        case .JoinMatch:
            let matchId = json["match_id"].uIntValue
            nc.post(name: .joinedMatch, object: matchId)
            
        case .LeaveMatch:
            let matchId = json["match_id"].uIntValue
            nc.post(name: .opponentLeavedMatch, object: matchId)
            break
            
        case .InvitePlayer:
            let senderPlayerId = json["sender"].stringValue
            nc.post(name: .matchInvitationArrived, object: senderPlayerId)
            
        case .IgnoreInvitation:
            let recipientPlayerId = json["recipient"].stringValue
            nc.post(name: .matchInvitationIgnored, object: recipientPlayerId)
            
        case .TextMessage:
            nc.post(name: .matchReceivedTextMessage, object: json.dictionaryObject!)
            break
            
            
        case .Turn:
            let matchId = json["match_id"].uIntValue
            guard matchId == Match.shared.id else {
                return
            }
            let params = json["params"]
            let turn = Turn(rawValue: json["turn"].intValue)!
            switch turn
            {
            case .rollDice:
                let playerId = json["id"].stringValue
                let values = params["values"].arrayObject as! [UInt]
                let rounds = params["rounds"].arrayObject as! [[Int]]
                guard let player = Match.shared.player(playerId) else {return}
                player.activeRotationRounds = rounds
                player.diceValues = values
                PlayViewController.diceScene.rollToValues(values, ctMaxRounds: 3, activeRotationRounds: rounds, ctHeld: player.diceHeld.count, completion: {})
                
            case .holdDice:
                let holdDice = params.arrayObject as! [UInt]
                let playerId = json["id"].stringValue
                guard let player = Match.shared.player(playerId) else {return}
                player.diceHeld = Set(holdDice)
                
            case .nextPlayer:
                Match.shared.nextPlayer()
                
            case .setValueAtTablePos:
                let playerId = json["id"].stringValue
                let posColIdx = params["posColIdx"].intValue
                let posRowIdx = params["posRowIdx"].intValue
                let value = params["value"].uInt
                guard let player = Match.shared.player(playerId) else {return}
                player.table.values[posColIdx][posRowIdx] = value
                
            case .inputPos:
                let playerId = json["id"].stringValue
                guard let player = Match.shared.player(playerId) else {return}
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
            case .newGame:
                nc.post(name: .opponentNewGame, object: matchId)
                
            case .end:
                nc.post(name: .multiplayerMatchEnded, object: matchId)
            }
            nc.post(name: .matchStateChanged, object: nil)
            
        default:
            break
        }
    }
}


