//
//  TableCol.swift
//  Yamb
//
//  Created by Kresimir Prcela on 22/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum TableCol: Int
{
    case down = 1
    case up
    case upDown
    case n
    case sum
    
    func name() -> String
    {
        switch self {
        case .down:
            return "↓"
        case .up:
            return "↑"
        case .upDown:
            return "⇅"
        case .n:
            return "N"
        case .sum:
            return "∑"
        }
    }
}
