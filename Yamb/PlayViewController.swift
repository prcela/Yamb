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
        
        collectionView.reloadData()
    }
    
    @IBAction func back(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func roll(sender: AnyObject)
    {
        DiceScene.shared.roll()
    }
}

extension PlayViewController: UICollectionViewDelegate
{
    
}

extension PlayViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionSize = collectionView.frame.size
        let ctRows = collectionView.numberOfItemsInSection(0)
        let ctSections = collectionView.numberOfSections()
        return CGSizeMake(collectionSize.width/CGFloat(ctRows), collectionSize.height/CGFloat(ctSections))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsZero
    }
    
    
}