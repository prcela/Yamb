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
let ipCurrent = ipWork

class WsAPI
{
    static let shared = WsAPI()
    private var retryCount = 0
    private var unsentMessages = [NSData]()
    
    var socket: WebSocket
    
    init() {
        
        let strURL = "ws://\(ipCurrent)/chat/"
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
        let avgScore6 = PlayerStat.avgScore(.Six)
        let diamonds = PlayerStat.shared.diamonds
        let json = JSON(["id":playerId,"alias":playerAlias,"avg_score_6":avgScore6,"diamonds":diamonds])
        send(.Join, json:json)
    }
    
    func roomInfo()
    {
        send(.RoomInfo)
    }
    
    func createMatch(diceNum: DiceNum, diceMaterials: [DiceMaterial], bet: Int)
    {
        let json = JSON([
            "dice_num":diceNum.rawValue,
            "bet":bet,
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
        let defaults = NSUserDefaults.standardUserDefaults()
        let playerId = defaults.stringForKey(Prefs.playerId)!
        var json = JSON(["match_id":matchId,"turn":turn.rawValue])
        json["params"] = params
        json["id"].string = playerId
        send(.Turn, json: json)
    }
    
    func invitePlayer(player: Player)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let playerId = defaults.stringForKey(Prefs.playerId)!
        let json = JSON(["sender":playerId, "recipient":player.id!])
        send(.InvitePlayer, json: json)
        
        // TODO: Show invited popup ...
    }
    
    func ignoreInvitation(senderPlayerId: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let playerId = defaults.stringForKey(Prefs.playerId)!
        let json = JSON(["recipient":playerId, "sender":senderPlayerId])
        send(.IgnoreInvitation, json: json)
    }
    
    func updatePlayer()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let alias = defaults.stringForKey(Prefs.playerAlias)!
        let diamonds = PlayerStat.shared.diamonds
        let avgScore6 = PlayerStat.avgScore(.Six)
        let json = JSON(["alias":alias, "diamonds":diamonds, "avg_score_6":avgScore6])
        send(.UpdatePlayer, json: json)
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
        
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {return}
        let json = JSON(data: data)
        
        guard let msgFunc = MessageFunc(rawValue: json["msg_func"].stringValue) else {
            return
        }
        
        switch msgFunc
        {
        
        case .Join:
            print("some player joined")
            
        case .Disconnected:
            print("someone disjoined")
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.disconnected, object: json["id"].stringValue)
        
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
                matchInfo.state = MatchState(rawValue: m["state"].stringValue)!
                matchInfo.playerIds = m["players"].arrayObject as! [String]
                matchInfo.diceNum = m["dice_num"].intValue
                matchInfo.diceMaterials = m["dice_materials"].arrayObject as! [String]
                Room.main.matchesInfo.append(matchInfo)
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
            
        case .InvitePlayer:
            let senderPlayerId = json["sender"].stringValue
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchInvitationArrived, object: senderPlayerId)
            
        case .IgnoreInvitation:
            let recipientPlayerId = json["recipient"].stringValue
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchInvitationIgnored, object: recipientPlayerId)
            
            
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
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.opponentNewGame, object: matchId)
                
            case .End:
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.multiplayerMatchEnded, object: matchId)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.matchStateChanged, object: nil)
            
        default:
            break
        }
    }
}


