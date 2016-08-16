//
//  PlayViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
        
    }
}
