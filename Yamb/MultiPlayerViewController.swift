//
//  MultiPlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 30/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import GameKit

class MultiPlayerViewController: UIViewController
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func localMatch(sender: AnyObject)
    {
        Match.shared.start(.LocalMultiplayer, diceNum: Match.shared.diceNum, playersDesc: [(nil,nil,DiceMaterial.Blue),(nil,nil,DiceMaterial.Red)], bet: 0)
        MainViewController.shared?.performSegueWithIdentifier("playIdentifier", sender: nil)
    }
        
}

