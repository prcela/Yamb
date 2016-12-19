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

    var favDiceMat:DiceMaterial = .White {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.playerFavDiceChanged, object: diamonds)
        }
    }
    var boughtDiceMaterials = [DiceMaterial]()
    
    var id: String = ""
    var alias: String = ""
    var items = [StatItem]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.playerStatItemsChanged, object: items)
        }
    }
    var purchasedName = false
    var diamonds = 100 {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.playerDiamondsChanged, object: diamonds)
        }
    }
    
    override init() {
        id = String(arc4random())
        alias = lstr("Player") + "_" + id
        super.init()
    }
    
    func ownsDiceMat(diceMat: DiceMaterial) -> Bool
    {
        if DiceMaterial.forFree().contains(diceMat)
        {
            return true
        }
        return boughtDiceMaterials.contains(diceMat)
    }
    
    func ownedDiceMaterials() -> [DiceMaterial]
    {
        let owned = DiceMaterial.forFree() + boughtDiceMaterials
        return owned
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
            
            // keep the old id and alias if still exist
            let def = NSUserDefaults.standardUserDefaults()
            if let id = def.objectForKey(Prefs.playerId_Deprecated) as? String
            {
                shared.id = id
                def.removeObjectForKey(Prefs.playerId_Deprecated)
            }
            if let alias = def.objectForKey(Prefs.playerAlias_Deprecated) as? String
            {
                shared.alias = alias
                def.removeObjectForKey(Prefs.playerAlias_Deprecated)
            }
        }
        
        
    }
    
    class func saveStat()
    {
        NSKeyedArchiver.archiveRootObject(shared, toFile: filePath())
        print("Saved stat")
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
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(alias, forKey: "alias")
        aCoder.encodeInteger(diamonds, forKey: "diamonds")
        aCoder.encodeObject(items, forKey: "items")
        aCoder.encodeObject(favDiceMat.rawValue, forKey: "favDiceMat")
        aCoder.encodeBool(purchasedName, forKey: "purchasedName")
        
        aCoder.encodeObject(boughtDiceMaterials.map({ (diceMat) -> String in
            return diceMat.rawValue
        }), forKey: "boughtDiceMaterials")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        if aDecoder.containsValueForKey("id")
        {
            id = aDecoder.decodeObjectForKey("id") as! String
        }
        else
        {
            id = String(arc4random())
        }
        
        if aDecoder.containsValueForKey("alias")
        {
            alias = aDecoder.decodeObjectForKey("alias") as! String
        }
        else
        {
            alias = lstr("Player") + "_" + id
        }
        
        diamonds = aDecoder.decodeIntegerForKey("diamonds")
        items = aDecoder.decodeObjectForKey("items") as! [StatItem]
        if aDecoder.containsValueForKey("favDiceMat")
        {
            favDiceMat = DiceMaterial(rawValue: aDecoder.decodeObjectForKey("favDiceMat") as! String)!
        }
        if aDecoder.containsValueForKey("purchasedName")
        {
            purchasedName = aDecoder.decodeBoolForKey("purchasedName")
        }
        if aDecoder.containsValueForKey("boughtDiceMaterials")
        {
            boughtDiceMaterials = (aDecoder.decodeObjectForKey("boughtDiceMaterials") as! [String]).map({ (rawName) -> DiceMaterial in
                return DiceMaterial(rawValue: rawName)!
            })
        }
        super.init()
    }

}
