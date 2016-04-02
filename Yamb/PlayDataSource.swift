//
//  PlayDataSource.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

enum PlaySection: Int {
    case Header = 0
    case Numbers // 1..6
    case SumNumbers
    case MaxMin // max, min
    case SumMaxMin
    case Skala
    case Full
    case Poker
    case Yamb
    case SumSFPY
}

class PlayDataSource: NSObject, UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let ctItemsInRow = 5 // ili 4
        switch PlaySection(rawValue: section)! {
        case .Header:
            return 1 * ctItemsInRow
        case .Numbers:
            return 6 * ctItemsInRow
        case .SumNumbers:
            return ctItemsInRow
        case .MaxMin:
            return 2 * ctItemsInRow
        case .SumMaxMin:
            return ctItemsInRow
        case .Skala:
            return ctItemsInRow
        case .Full:
            return ctItemsInRow
        case .Poker:
            return ctItemsInRow
        case .Yamb:
            return ctItemsInRow
        case .SumSFPY:
            return ctItemsInRow
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch PlaySection(rawValue: indexPath.section)! {
        case .Header:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
            return cell
        case .Numbers:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        default:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
            return cell
        }
    }

}
