//
//  DiceMaterial.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum DiceMaterial: String
{
    case White = "a"
    case Black = "b"
    case Rose = "c"
    case Blue = "d"
    case Red = "e"
    case Yellow = "f"
    case BlueGlass = "g"
    case Roman = "h"
    case RedGlass = "i"
    case Heart = "j"
    
    static func all() -> [DiceMaterial]
    {
        return [.White, .Black, .Blue, .Rose, .Red, .Yellow, .BlueGlass, .Roman, .RedGlass, .Heart]
    }
    
    func iconForValue(value: Int, selected: Bool = false) -> UIImage?
    {
        var name = "\(value)\(rawValue)"
        if selected
        {
            name = name + "_sel"
        }
        return UIImage(named: name)
    }

}

func diceIcon(materialName: String, value: Int, selected: Bool = false) -> UIImage?
{
    var diceMat = DiceMaterial(rawValue: materialName)
    if diceMat == nil
    {
        diceMat = .White
    }
    return diceMat?.iconForValue(value, selected: selected)
}
