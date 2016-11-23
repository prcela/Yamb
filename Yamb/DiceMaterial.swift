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
    
    static func all() -> [DiceMaterial]
    {
        return [.White, .Black, .Blue, .Rose, .Red, .Yellow]
    }

}
