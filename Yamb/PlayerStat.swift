//
//  StatHelper.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class PlayerStat: NSObject, NSCoding
{
    static var shared = PlayerStat()
    
    var items = [StatItem]()
    var diamonds = 100 {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.playerDiamondsChanged, object: diamonds)
        }
    }
    
    override init() {
        super.init()
    }
    
    private class func filePath() -> String
    {
        let docURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: [.UserDomainMask]).first!
        let filePath = docURL.URLByAppendingPathComponent("PlayerStat")!.path!
        return filePath
    }
    
    class func loadStat()
    {
        if NSFileManager.defaultManager().fileExistsAtPath(filePath())
        {
            shared = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath()) as! PlayerStat
        }
    }
    
    class func saveStat()
    {
        NSKeyedArchiver.archiveRootObject(shared, toFile: filePath())
    }
    
    class func avgScore(diceNum: DiceNum) -> Float
    {
        var sum:Float = 0
        var ct = 0
        for item in shared.items
        {
            if item.diceNum == diceNum
            {
                ct += 1
                sum += Float(item.score)
            }
        }
        if ct > 0
        {
            return sum/Float(ct)
        }
        return 0
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeInteger(diamonds, forKey: "diamonds")
        aCoder.encodeObject(items, forKey: "items")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        items = aDecoder.decodeObjectForKey("items") as! [StatItem]
        super.init()
    }

}
