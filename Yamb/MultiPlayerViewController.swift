//
//  MultiPlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 30/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import GameKit

class MultiPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GameKitHelper.shared.findMatchWithMinPlayers(2, maxPlayers: 2, vc: self, delegate: self)
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

extension MultiPlayerViewController: GameKitHelperDelegate
{
    func matchStarted() {
        print("match started")
    }
    
    func matchEnded() {
        print("match ended")
    }
    
    func matchDidReceiveData(match: GKMatch, data: NSData, fromPlayerId: String) {
        print("Received data")
    }
}
