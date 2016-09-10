//
//  Match15ViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 08/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class Match15ViewController: UIViewController {
    
    var socket: WebSocket?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        socket = WebSocket(url: NSURL(string: "ws://localhost:8080/chat/")!)
        socket?.headers["Sec-WebSocket-Protocol"] = "no-body"
        socket?.delegate = self
        socket?.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Match15ViewController: WebSocketDelegate
{
    func websocketDidConnect(socket: WebSocket) {
        print("didConnect")
        
        let payload = ["msg_func":"join","gc_id":"1","alias":"kreso"]
        let data = try! NSJSONSerialization.dataWithJSONObject(payload, options: [])
        socket.writeData(data)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("websocketDidReceiveData")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocketDidDisconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("websocketDidReceiveMessage: \(text)")
        
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {return}
        let json = JSON(data: data)
        
        switch MessageFunc(rawValue: json["msg_func"].stringValue)!
        {
        case .Join:
            print("joined")
        default:
            break
        }
    }
}
