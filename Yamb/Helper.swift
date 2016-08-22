//
//  Helper.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import UIKit

func dispatchToMainQueue(delay delay:NSTimeInterval, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


func isSmallScreen() -> Bool
{
    return CGRectGetHeight(UIScreen.mainScreen().bounds) <= 568
}