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
    
    class func score(json:JSON, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let jsonData = try! json.rawData()
        let url = NSURL(string: "http://\(ipCurrent)/score")!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Accept")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("\(jsonData.length)", forHTTPHeaderField:"Content-Length")
        request.HTTPBody = jsonData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func scores(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let url = NSURL(string: "http://\(ipCurrent)/scores")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }
}
