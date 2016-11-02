//
//  StatHelper.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class StatHelper: NSObject, NSCoding
{
    static var shared = StatHelper()
    
    var items = [StatItem]()
    
    override init() {
        super.init()
    }
    
    private class func filePath() -> String
    {
        let docURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: [.UserDomainMask]).first!
        let filePath = docURL.URLByAppendingPathComponent("Stat")!.path!
        return filePath
    }
    
    class func loadStat()
    {
        if NSFileManager.defaultManager().fileExistsAtPath(filePath())
        {
            shared = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath()) as! StatHelper
        }
    }
    
    class func saveStat()
    {
        NSKeyedArchiver.archiveRootObject(shared, toFile: filePath())
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(items, forKey: "items")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        items = aDecoder.decodeObjectForKey("items") as! [StatItem]
        super.init()
    }

}
