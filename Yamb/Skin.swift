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
    static let red = Skin(strokeColor: UIColor.red, labelBackColor: UIColor(netHex:0x88ff6666), tintColor: UIColor.red)
    
    let lightGrayColor = UIColor.lightGray.withAlphaComponent(0.1)
    var strokeColor = UIColor.blue
    var labelBackColor = UIColor(netHex:0xaaa6b5FF)
    var tintColor = UIColor.blue
    let defaultLightColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
}
