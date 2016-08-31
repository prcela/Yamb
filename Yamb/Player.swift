//
//  Player.swift
//  Yamb
//
//  Created by Kresimir Prcela on 30/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

private let keyId = "letKeyId"
private let keyTable = "keyTable"

class Player: NSObject, NSCoding
{
    var id: String?
    var table = Table()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey(keyId) as? String
        table = aDecoder.decodeObjectForKey(keyTable) as! Table
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(id, forKey: keyId)
        aCoder.encodeObject(table, forKey: keyTable)
    }
}