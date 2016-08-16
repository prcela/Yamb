//
//  PlayViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SceneKit

class PlayViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.scene = DiceScene.shared

    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
        
    }
}
