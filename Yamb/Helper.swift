//
//  Helper.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import UIKit

func dispatchToMainQueue(delay:TimeInterval, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + delay, execute: closure)
}


func isSmallScreen() -> Bool
{
    return UIScreen.main.bounds.height <= 568
}

func lstr(_ key: String) -> String
{
    return NSLocalizedString(key, comment: "")
}
