//
//  GameFileManager.swift
//  Yamb
//
//  Created by Kresimir Prcela on 01/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class GameFileManager
{
    class func filePathForGameName(gameName: String) -> String
    {
        let docURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: [.UserDomainMask]).first!
        let filePath = docURL.URLByAppendingPathComponent(gameName)!.path!
        return filePath
    }
    
    class func saveMatch(match: Match)
    {
        let matchName = match.matchType.rawValue
        NSKeyedArchiver.archiveRootObject(match, toFile: filePathForGameName(matchName))
        print("Match saved")
    }
    
    class func existsSavedGame(gameName: String) -> Bool
    {
        let filePath = filePathForGameName(gameName)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }
    
    class func loadMatch(matchType: MatchType) -> Match?
    {
        let filePath = filePathForGameName(matchType.rawValue)
        if NSFileManager.defaultManager().fileExistsAtPath(filePath)
        {
            let match = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? Match
            print("Match loaded")
            return match
        }
        return nil
    }
    
    class func deleteGame(gameName: String) -> Bool
    {
        let filePath = filePathForGameName(gameName)
        if let _ = try? NSFileManager.defaultManager().removeItemAtPath(filePath)
        {
            print("Game deleted")
            return true
        }
        return false
    }
}
