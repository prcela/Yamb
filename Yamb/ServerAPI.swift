//
//  ServerAPI.swift
//  Yamb
//
//  Created by Kresimir Prcela on 28/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerAPI
{
    class func info(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://\(ipCurrent)/info")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: completionHandler)
        
        task.resume()
    }
    
    fileprivate class func jsonRequest(_ json:JSON, url: URL) -> URLRequest
    {
        let jsonData = try! json.rawData()
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Accept")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("\(jsonData.count)", forHTTPHeaderField:"Content-Length")
        request.httpBody = jsonData
        return request
    }
    
    class func statItem(_ json:JSON, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://\(ipCurrent)/statItem")!
        let request = jsonRequest(json, url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func updatePlayer(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let playerId = PlayerStat.shared.id
        let alias = PlayerStat.shared.alias
        let diamonds = PlayerStat.shared.diamonds
        let avgScore5 = PlayerStat.avgScore(.five)
        let avgScore6 = PlayerStat.avgScore(.six)
        
        let json = JSON([
            "id": playerId,
            "alias": alias,
            "diamonds": diamonds,
            "avg_score_5": avgScore5,
            "avg_score_6": avgScore6])
        
        let url = URL(string: "http://\(ipCurrent)/updatePlayer")!
        let request = jsonRequest(json, url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func score(_ json:JSON, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://\(ipCurrent)/score")!
        let request = jsonRequest(json, url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    class func scores(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://\(ipCurrent)/scores")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: completionHandler)
        task.resume()
    }
    
    class func players(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://\(ipCurrent)/players")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: completionHandler)
        task.resume()
    }
    
    class func statItems(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://\(ipCurrent)/statItems")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: completionHandler)
        task.resume()
    }
    
    
}
