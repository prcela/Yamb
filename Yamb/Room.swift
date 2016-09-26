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
    var freePlayers = [Player]()
    var matchesInfo = [MatchInfo]()
    
    func matchInfo(id: UInt) -> MatchInfo?
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
    
    func matchesInfo(state: MatchState) -> [MatchInfo]
    {
        return matchesInfo.filter({ (match) -> Bool in
            return match.state == state
        })
    }
    
    func matchesInfo(playerId: String) -> [MatchInfo]
    {
        return matchesInfo.filter({ (match) -> Bool in
            return match.players.contains({ (player) -> Bool in
                return player.id == playerId
            })
        })
    }
}
