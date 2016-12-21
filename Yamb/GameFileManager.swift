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
    class func filePathForGameName(_ gameName: String) -> String
    {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: [.userDomainMask]).first!
        let filePath = docURL.appendingPathComponent(gameName).path
        return filePath
    }
    
    class func saveMatch(_ match: Match)
    {
        let matchName = match.matchType.rawValue
        NSKeyedArchiver.archiveRootObject(match, toFile: filePathForGameName(matchName))
        print("Match saved")
    }
    
    class func existsSavedGame(_ gameName: String) -> Bool
    {
        let filePath = filePathForGameName(gameName)
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    class func loadMatch(_ matchType: MatchType) -> Match?
    {
        let filePath = filePathForGameName(matchType.rawValue)
        if FileManager.default.fileExists(atPath: filePath)
        {
            let match = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Match
            print("Match loaded")
            return match
        }
        return nil
    }
    
    class func deleteGame(_ gameName: String) -> Bool
    {
        let filePath = filePathForGameName(gameName)
        if let _ = try? FileManager.default.removeItem(atPath: filePath)
        {
            print("Game deleted")
            return true
        }
        return false
    }
}
