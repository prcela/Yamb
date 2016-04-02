//
//  PlayFlowLayout.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PlayFlowLayout: UICollectionViewFlowLayout
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let w = CGRectGetWidth(UIScreen.mainScreen().bounds)
        
        if w > 320 {
            itemSize = CGSizeMake(70, 25)
        } else {
            itemSize = CGSizeMake(57.5, 25)
        }
        
        sectionInset = UIEdgeInsetsZero
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }

}
