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
    
    func diceMaterial(_ indexPath: IndexPath) -> DiceMaterial
    {
        var diceMat = DiceMaterial.White
        if indexPath.section == 0
        {
            diceMat = DiceMaterial.forFree[indexPath.row]
        }
        else if indexPath.section == 1
        {
            diceMat = DiceMaterial.forDiamonds[indexPath.row]
        }
        else if indexPath.section == 2
        {
            diceMat = DiceMaterial.forBuy[indexPath.row]
        }
        return diceMat
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                               withReuseIdentifier: "DiceHeader",
                                                                               for: indexPath) as! DiceHeader
        let titles = [lstr("Dice"),
                      String(format: "%d 💎", DiceMaterial.diamondsPrice()),
                      "Extra"]
        
        headerView.lbl.text = titles[indexPath.section]
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0
        {
            return DiceMaterial.forFree.count
        }
        else if section == 1
        {
            return DiceMaterial.forDiamonds.count
        }
        else if section == 2
        {
            return DiceMaterial.forBuy.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiceCell", for: indexPath) as! DiceCell
        
        let diceMat = diceMaterial(indexPath)
        cell.update(diceMat)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        let diceMat = diceMaterial(indexPath)
        if PlayerStat.shared.ownsDiceMat(diceMat)
        {
            return true
        }
        else
        {
            NotificationCenter.default.post(name: .wantsUnownedDiceMaterial, object: diceMat.rawValue)
            return false
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        var diceMat: DiceMaterial?
        if indexPath.section == 0
        {
            diceMat = DiceMaterial.forFree[indexPath.row]
        }
        else if indexPath.section == 1
        {
            diceMat = DiceMaterial.forDiamonds[indexPath.row]
        }
        else if indexPath.section == 2
        {
            diceMat = DiceMaterial.forBuy[indexPath.row]
        }
        
        if diceMat != nil
        {
            PlayerStat.shared.favDiceMat = diceMat!
        }
    }
}
