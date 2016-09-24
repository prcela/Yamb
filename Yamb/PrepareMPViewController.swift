//
//  PrepareMPViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PrepareMPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func createMatch(sender: AnyObject) {
        WsAPI.shared.createMatch()
    }
}
