//
//  WsAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import GameKit

private let ipHome = "192.168.5.11:8080"
private let ipWork = "10.0.21.221:8080"
private let ipServer = "139.59.142.160:80"
let ipCurrent = ipServer

class WsAPI
{
    static let shared = WsAPI()
    private var retryCount = 0
    private var unsentMessages = [String]()
    private var pingInterval: NSTimeInterval = 30
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipCurrent)/chat/"
        socket = WebSocket(url: NSURL(string: strURL)!)
        socket.headers["Sec-WebSocket-Protocol"] = "no-body"
        socket.delegate = self
        
        dispatchToMainQueue(delay: pingInterval) { 
            self.ping()
        }
    }
    
    func connect()
    {
        socket.connect()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.wsConnect, object: nil)
    }
    
    func ping()
    {
        print("ping")
        socket.writePing(NSData())
        dispatchToMainQueue(delay: pingInterval) {
            self.ping()
        }
    }
    
    func joinToRoom()
    {
        let playerId = PlayerStat.shared.id
        let playerAlias = PlayerStat.shared.alias
        let avgScore6 = PlayerStat.avgScore(.Six)
        let diamonds = PlayerStat.shared.diamonds
        let json = JSON(["id":playerId,"alias":playerAlias,"avg_score_6":avgScore6,"diamonds":diamonds])
        send(.Join, json:json)
    }
    
    func roomInfo()
    {
        send(.RoomInfo)
    }
    
    func createMatch(diceNum: DiceNum, isPrivate: Bool, diceMaterials: [DiceMaterial], bet: Int)
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
    
    func joinToMatch(matchId: UInt, ownDiceMat: DiceMaterial)
    {
        let json = JSON(["match_id":matchId, "dice_mat":ownDiceMat.rawValue])
        send(.JoinMatch, json: json)
    }
    
    func leaveMatch(matchId: UInt)
    {
        let json = JSON(["match_id":matchId])
        send(.LeaveMatch, json: json)
    }
    
    func turn(turn: Turn, matchId: UInt, params: JSON)
    {
        let playerId = PlayerStat.shared.id
        var json = JSON(["match_id":matchId,"turn":turn.rawValue])
        json["params"] = params
        json["id"].string = playerId
        send(.Turn, json: json)
    }
    
    func invitePlayer(player: Player)
    {
        let playerId = PlayerStat.shared.id
        let json = JSON(["sender":playerId, "recipient":player.id!])
        send(.InvitePlayer, json: json)
        
        // TODO: Show invited popup ...
    }
    
    func ignoreInvitation(senderPlayerId: String)
    {
        let playerId = PlayerStat.shared.id
        let json = JSON(["recipient":playerId, "sender":senderPlayerId])
        send(.IgnoreInvitation, json: json)
    }
    
    func sendTextMessage(recipient: Player, text: String)
    {
        let playerId = PlayerStat.shared.id
        let json = JSON(["sender":playerId, "recipient":recipient.id!, "text": text])
        send(.TextMessage, json: json)
    }
    
    
    private func send(action: MessageFunc, json: JSON? = nil)
    {
        var json = json ?? JSON([:])
        json["msg_func"].string = action.rawValue
        
        if let text = json.rawString(NSUTF8StringEncoding, options: [])
        {
            if socket.isConnected
            {
                print("Sending:\n\(text)")
                socket.writeString(text)
            }
            else
            {
                print("Keeping:\n\(text)")
                unsentMessages.append(text)
            }
        }
    }
    
    private func sendUnsentMessages()
    {
        guard socket.isConnected else {
            return
        }
        for text in unsentMessages
        {
            socket.writeString(text)
        }
        unsentMessages.removeAll()
    }
}

extension WsAPI: WebSocketDelegate
{
    func websocketDidConnect(socket: WebSocket) {
        print("didConnect to \(socket.currentURL)")
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.wsDidConnect, object: nil)
        retryCount = 0
        joinToRoom()
        sendUnsentMessages()
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocketDidDisconnect")
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.wsDidDisconnect, object: nil)
        
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
            socket.writeString(JSON(["ack":msgId]).rawString()!)
        }
        
        guard let msgFunc = MessageFunc(rawValue: json["msg_func"].stringValue) else {
            return
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        
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
            nc.postNotificationName(NotificationName.maybeSomeoneWillDump, object: json["id"].stringValue)
            
        case .Dump:
            print("someone dumped")
            let matchId = json["match_id"].uIntValue
            guard matchId == Match.shared.id else {
                return
            }
            nc.postNotificationName(NotificationName.dumped, object: json["id"].stringValue)
        
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
            
            nc.postNotificationName(NotificationName.onRoomInfo, object: nil)
            
        case .CreateMatch:
            print("Match created")
            
        case .JoinMatch:
            let matchId = json["match_id"].uIntValue
            nc.postNotificationName(NotificationName.joinedMatch, object: matchId)
            
        case .LeaveMatch:
            let matchId = json["match_id"].uIntValue
            nc.postNotificationName(NotificationName.opponentLeavedMatch, object: matchId)
            break
            
        case .InvitePlayer:
            let senderPlayerId = json["sender"].stringValue
            nc.postNotificationName(NotificationName.matchInvitationArrived, object: senderPlayerId)
            
        case .IgnoreInvitation:
            let recipientPlayerId = json["recipient"].stringValue
            nc.postNotificationName(NotificationName.matchInvitationIgnored, object: recipientPlayerId)
            
        case .TextMessage:
            nc.postNotificationName(NotificationName.matchReceivedTextMessage, object: json.dictionaryObject!)
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
            case .RollDice:
                let playerId = json["id"].stringValue
                let values = params["values"].arrayObject as! [UInt]
                let rounds = params["rounds"].arrayObject as! [[Int]]
                guard let player = Match.shared.player(playerId) else {return}
                player.activeRotationRounds = rounds
                player.diceValues = values
                DiceScene.shared.rollToValues(values, ctMaxRounds: 3, completion: {})
                
            case .HoldDice:
                let holdDice = params.arrayObject as! [UInt]
                let playerId = json["id"].stringValue
                guard let player = Match.shared.player(playerId) else {return}
                player.diceHeld = Set(holdDice)
                
            case .NextPlayer:
                Match.shared.nextPlayer()
                
            case .SetValueAtTablePos:
                let playerId = json["id"].stringValue
                let posColIdx = params["posColIdx"].intValue
                let posRowIdx = params["posRowIdx"].intValue
                let value = params["value"].uInt
                guard let player = Match.shared.player(playerId) else {return}
                player.table.values[posColIdx][posRowIdx] = value
                
            case .InputPos:
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
            case .NewGame:
                nc.postNotificationName(NotificationName.opponentNewGame, object: matchId)
                
            case .End:
                nc.postNotificationName(NotificationName.multiplayerMatchEnded, object: matchId)
            }
            nc.postNotificationName(NotificationName.matchStateChanged, object: nil)
            
        default:
            break
        }
    }
}


