//
//  DiceCollectionViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class DiceCollectionViewController: UICollectionViewController
{
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func diceMaterial(indexPath: NSIndexPath) -> DiceMaterial
    {
        var diceMat = DiceMaterial.White
        if indexPath.section == 0
        {
            diceMat = DiceMaterial.forFree()[indexPath.row]
        }
        else if indexPath.section == 1
        {
            diceMat = DiceMaterial.forDiamonds()[indexPath.row]
        }
        else if indexPath.section == 2
        {
            diceMat = DiceMaterial.forBuy()[indexPath.row]
        }
        return diceMat
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                                                                                   withReuseIdentifier: "DiceHeader",
                                                                                   forIndexPath: indexPath) as! DiceHeader
            let titles = ["Free","Get for 💎","Extra"]
            headerView.lbl.text = titles[indexPath.section]
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0
        {
            return DiceMaterial.forFree().count
        }
        else if section == 1
        {
            return DiceMaterial.forDiamonds().count
        }
        else if section == 2
        {
            return DiceMaterial.forBuy().count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiceCell", forIndexPath: indexPath) as! DiceCell
        
        let diceMat = diceMaterial(indexPath)
        cell.update(diceMat)
        return cell
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        let diceMat = diceMaterial(indexPath)
        if PlayerStat.shared.ownsDiceMat(diceMat)
        {
            return true
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.wantsUnownedDiceMaterial, object: diceMat.rawValue)
            return false
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var diceMat: DiceMaterial?
        if indexPath.section == 0
        {
            diceMat = DiceMaterial.forFree()[indexPath.row]
        }
        else if indexPath.section == 1
        {
            diceMat = DiceMaterial.forDiamonds()[indexPath.row]
        }
        else if indexPath.section == 2
        {
            diceMat = DiceMaterial.forBuy()[indexPath.row]
        }
        
        if diceMat != nil
        {
            PlayerStat.shared.favDiceMat = diceMat!
        }
    }
}
