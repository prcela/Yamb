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
}
