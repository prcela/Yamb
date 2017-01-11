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
            NotificationCenter.default.post(name: .playerFavDiceChanged, object: diamonds)
        }
    }
    var boughtDiceMaterials = [DiceMaterial]()
    
    var id: String = ""
    var alias: String = ""
    var items = [StatItem]() {
        didSet {
            NotificationCenter.default.post(name: .playerStatItemsChanged, object: items)
        }
    }
    var purchasedName = false
    var diamonds = 100 {
        didSet {
            print("Diamonds didSet: \(diamonds)")
            NotificationCenter.default.post(name: .playerDiamondsChanged, object: diamonds)
        }
    }
    
    // retention days in era
    var retentions = [Int]()
    
    override init() {
        id = String(arc4random())
        alias = lstr("Player") + "_" + id
        super.init()
    }
    
    func ownsDiceMat(_ diceMat: DiceMaterial) -> Bool
    {
        if DiceMaterial.forFree.contains(diceMat)
        {
            return true
        }
        return boughtDiceMaterials.contains(diceMat)
    }
    
    func ownedDiceMaterials() -> [DiceMaterial]
    {
        let owned = DiceMaterial.forFree + boughtDiceMaterials
        return owned
    }
    
    fileprivate class func filePath() -> String
    {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: [.userDomainMask]).first!
        let filePath = docURL.appendingPathComponent("PlayerStat").path
        return filePath
    }
    
    class func loadStat()
    {
        if FileManager.default.fileExists(atPath: filePath())
        {
            shared = NSKeyedUnarchiver.unarchiveObject(withFile: filePath()) as! PlayerStat
            
            // keep the old id and alias if still exist
            let def = UserDefaults.standard
            if let id = def.object(forKey: Prefs.playerId_Deprecated) as? String
            {
                shared.id = id
                def.removeObject(forKey: Prefs.playerId_Deprecated)
            }
            if let alias = def.object(forKey: Prefs.playerAlias_Deprecated) as? String
            {
                shared.alias = alias
                def.removeObject(forKey: Prefs.playerAlias_Deprecated)
            }
        }
        
        
    }
    
    class func saveStat()
    {
        NSKeyedArchiver.archiveRootObject(shared, toFile: filePath())
        print("Saved stat")
    }
    
    class func avgScore(_ diceNum: DiceNum) -> Float
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
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(alias, forKey: "alias")
        aCoder.encode(diamonds, forKey: "diamonds")
        aCoder.encode(items, forKey: "items")
        aCoder.encode(favDiceMat.rawValue, forKey: "favDiceMat")
        aCoder.encode(purchasedName, forKey: "purchasedName")
        
        aCoder.encode(boughtDiceMaterials.map({ (diceMat) -> String in
            return diceMat.rawValue
        }), forKey: "boughtDiceMaterials")
        aCoder.encode(retentions, forKey: "retentions")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        if aDecoder.containsValue(forKey: "id")
        {
            id = aDecoder.decodeObject(forKey: "id") as! String
        }
        else
        {
            id = String(arc4random())
        }
        
        if aDecoder.containsValue(forKey: "alias")
        {
            alias = aDecoder.decodeObject(forKey: "alias") as! String
        }
        else
        {
            alias = lstr("Player") + "_" + id
        }
        
        diamonds = aDecoder.decodeInteger(forKey: "diamonds")
        items = aDecoder.decodeObject(forKey: "items") as! [StatItem]
        if aDecoder.containsValue(forKey: "favDiceMat")
        {
            favDiceMat = DiceMaterial(rawValue: aDecoder.decodeObject(forKey: "favDiceMat") as! String)!
        }
        if aDecoder.containsValue(forKey: "purchasedName")
        {
            purchasedName = aDecoder.decodeBool(forKey: "purchasedName")
        }
        if aDecoder.containsValue(forKey: "boughtDiceMaterials")
        {
            boughtDiceMaterials = (aDecoder.decodeObject(forKey: "boughtDiceMaterials") as! [String]).map({ (rawName) -> DiceMaterial in
                return DiceMaterial(rawValue: rawName)!
            })
        }
        if aDecoder.containsValue(forKey: "retentions")
        {
            retentions = aDecoder.decodeObject(forKey: "retentions") as! [Int]
        }
        super.init()
    }

}
