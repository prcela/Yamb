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
    
    
    
    @IBOutlet weak var gameTableView: GameTableView!
    @IBOutlet weak var sceneView: SCNView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGameStateChanged(_:)), name: NotificationName.gameStateChanged, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.scene = DiceScene.shared
    }
    
    override func viewDidLayoutSubviews()
    {
        gameTableView.updateSubviews()
    }
    
    func onGameStateChanged(notification: NSNotification)
    {
//        collectionView.reloadData()
    }
    
    @IBAction func back(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func roll(sender: AnyObject)
    {
        Game.shared.roll()
    }
}

