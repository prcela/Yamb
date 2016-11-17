//
//  ServerAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 28/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class ServerAPI
{
    class func info(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/info")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: completionHandler)
        
        task.resume()
    }
    
    private class func jsonRequest(json:JSON, url: NSURL) -> NSMutableURLRequest
    {
        let jsonData = try! json.rawData()
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Accept")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("\(jsonData.length)", forHTTPHeaderField:"Content-Length")
        request.HTTPBody = jsonData
        return request
    }
    
    class func statItem(json:JSON, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/statItem")!
        let request = jsonRequest(json, url: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func updatePlayer(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let playerId = defaults.stringForKey(Prefs.playerId)!
        let alias = defaults.stringForKey(Prefs.playerAlias)!
        let diamonds = PlayerStat.shared.diamonds
        let avgScore5 = PlayerStat.avgScore(.Five)
        let avgScore6 = PlayerStat.avgScore(.Six)
        
        let json = JSON([
            "id": playerId,
            "alias": alias,
            "diamonds": diamonds,
            "avg_score_5": avgScore5,
            "avg_score_6": avgScore6])
        
        let url = NSURL(string: "http://\(ipCurrent)/updatePlayer")!
        let request = jsonRequest(json, url: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func score(json:JSON, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/score")!
        let request = jsonRequest(json, url: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func scores(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/scores")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    
    class func players(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/players")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    
    class func statItems(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/statItems")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
    
    
}
