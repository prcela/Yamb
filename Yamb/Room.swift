//
//  Room.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class Room
{
    static let main = Room()
    var players = [Player]()
    var matchesInfo = [MatchInfo]()
    
    func matchInfo(_ id: UInt) -> MatchInfo?
    {
        for m in matchesInfo
        {
            if m.id == id
            {
                return m
            }
        }
        return nil
    }
    
    func matchesInfo(_ state: MatchState) -> [MatchInfo]
    {
        return matchesInfo.filter({ (match) -> Bool in
            return match.state == state
        })
    }
    
    func matchesInfo(_ playerId: String) -> [MatchInfo]
    {
        return matchesInfo.filter({ (match) -> Bool in
            return match.playerIds.contains(playerId)
        })
    }
    
    func player(_ id: String) -> Player?
    {
        if let idx = players.index (where: { (p) -> Bool in
            return p.id == id
        }) {
            return players[idx]
        }
        return nil
    }
    
    func freePlayers() -> [Player]
    {
        var free = [Player]()
        for player in players
        {
            if matchesInfo.index(where: { (m) -> Bool in
                return m.playerIds.contains(player.id!)
            }) == nil
            {
                free.append(player)
            }
        }
        return free
    }
}
