//
//  ViewController.swift
//  Yamb
//
//  Created by prcela on 01/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

struct NotificationName
{
    static let play = "Play"
}

class RootViewController: UIViewController
{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(presentPlayViewController), name: NotificationName.play, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func presentPlayViewController()
    {
        performSegueWithIdentifier("playIdentifier", sender: nil)
    }


}

