//
//  DiceMaterial.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import Firebase

enum DiceMaterial: String
{
    case White = "a"
    case Black = "b"
    case Rose = "c"
    case Blue = "d"
    case Red = "e"
    case Yellow = "f"
    case Violet = "vi"
    case Elsa = "g"
    case Roman = "h"
    case RedGlass = "i"
    case Heart = "j"
    case Dark = "k"
    case Apple = "l"
    case Moon = "m"
    case Flower = "n"
    case Bombs = "o"
    case Numbers = "p"
    case Animal = "r"
    case Soccer = "s"
    case Xmass = "t"
    case Cheese = "u"
    case Green = "v"
    case Mario = "z"
    case Aurora = "x"
    case Flourescent = "y"
    case XO = "q"
    case GrayGlitter = "gg"
    
    static func diamondsPrice() -> Int
    {
        return FIRRemoteConfig.remoteConfig()["dice_price_diamonds"].numberValue!.integerValue
    }
    
    static let all = [White,Black,Rose,Blue,Red,Yellow,Violet,Elsa,Roman,RedGlass,Heart,Dark,Apple,Moon,Flower,Bombs,Numbers,Animal,Soccer,Xmass,Cheese,Green,Mario,Aurora,Flourescent,XO,GrayGlitter]
    static let forFree = [White, Black, Blue, Rose, Red, Yellow, Green, Violet, GrayGlitter]
    static let forDiamonds = [Roman, RedGlass, Heart, Dark, Flower, Moon, Bombs, Animal, Soccer, Xmass, Cheese, Flourescent, XO]
    static let forBuy = [Elsa, Numbers, Apple, Aurora, Mario]
    
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
