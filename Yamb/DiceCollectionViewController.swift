//
//  DiceCollectionViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class DiceCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                                                                                   withReuseIdentifier: "FreeDice",
                                                                                   forIndexPath: indexPath)
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DiceMaterial.all().count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiceCell", forIndexPath: indexPath) as! DiceCell
        cell.update(DiceMaterial.all()[indexPath.row])
        return cell
    }

}
