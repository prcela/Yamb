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
    var items = [StatItem]()
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
            
            // get the id and alias from prefs
            let def = NSUserDefaults.standardUserDefaults()
            if let id = def.objectForKey(Prefs.playerId) as? String
            {
                shared.id = id
            }
            if let alias = def.objectForKey(Prefs.playerAlias) as? String
            {
                shared.alias = alias
            }
        }
        
        
    }
    
    class func saveStat()
    {
        NSKeyedArchiver.archiveRootObject(shared, toFile: filePath())
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(shared.id, forKey: Prefs.playerId)
        defaults.setObject(shared.alias, forKey: Prefs.playerAlias)
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
