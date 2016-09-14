//
//  Skin.swift
//  Yamb
//
//  Created by Kresimir Prcela on 21/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import UIKit

struct Skin
{
    static let blue = Skin()
    static let red = Skin(strokeColor: UIColor.redColor(), labelBackColor: UIColor(netHex:0xaaff7777), tintColor: UIColor.redColor())
    
    let lightGrayColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1)
    var strokeColor = UIColor.blueColor()
    var labelBackColor = UIColor(netHex:0xaaa6b5FF)
    var tintColor = UIColor.blueColor()
    let defaultLightColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
}
