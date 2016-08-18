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
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
    case SumNumbers
    case Max
    case Min
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
        return 16
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let ctItemsInRow = Game.shared.useNajava ? 5:4
        return ctItemsInRow
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        
        switch PlaySection(rawValue: indexPath.section)! {
        case .Header:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
            let titles = ["","↓","↑","⇅","N"]
            cell.lbl.text = titles[indexPath.item]
            cell.lbl.font = UIFont.boldSystemFontOfSize(24)
            return cell
        case .One, .Two, .Three, .Four, .Five, .Six:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = String(indexPath.section)
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .SumNumbers:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
            if indexPath.item == 0
            {
                cell.lbl.text = "∑"
            }
            else
            {
            }
            return cell
        case .Max:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = "Max"
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .Min:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = "Min"
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .SumMaxMin:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
            if indexPath.item == 0
            {
                cell.lbl.text = "∑"
            }
            else
            {
            }
            return cell
        case .Skala:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = "Skala"
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .Full:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = "Full"
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .Poker:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = "Poker"
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .Yamb:
            if indexPath.item == 0
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
                cell.lbl.text = "Yamb"
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BtnCell", forIndexPath: indexPath) as! BtnCell
                return cell
            }
        case .SumSFPY:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LblCell", forIndexPath: indexPath) as! LblCell
            if indexPath.item == 0
            {
                cell.lbl.text = "∑"
            }
            else
            {
            }
            return cell
        }
    }

}
