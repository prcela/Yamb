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
    var matches = [MatchInfo]()
    
    func matches(state: MatchState) -> [MatchInfo]
    {
        return matches.filter({ (match) -> Bool in
            return match.state == state
        })
    }
}
