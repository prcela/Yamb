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
    
    class func saveGame(game: Game)
    {
        let gameName = game.players.count == 1 ? "singlePlayer":"multiPlayer"
        NSKeyedArchiver.archiveRootObject(game, toFile: filePathForGameName(gameName))
    }
    
    class func existsSavedGame(gameName: String) -> Bool
    {
        let filePath = filePathForGameName(gameName)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }
    
    class func loadGame(gameName: String) -> Game?
    {
        let filePath = filePathForGameName(gameName)
        if NSFileManager.defaultManager().fileExistsAtPath(filePath)
        {
            let game = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? Game
            return game
        }
        return nil
    }
    
    class func deleteGame(gameName: String) -> Bool
    {
        let filePath = filePathForGameName(gameName)
        if let _ = try? NSFileManager.defaultManager().removeItemAtPath(filePath)
        {
            return true
        }
        return false
    }
}
