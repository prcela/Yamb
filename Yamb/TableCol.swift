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
    case Down = 1
    case Up
    case UpDown
    case N
    case Sum
    
    func name() -> String
    {
        switch self {
        case .Down:
            return "↓"
        case .Up:
            return "↑"
        case .UpDown:
            return "⇅"
        case .N:
            return "N"
        case .Sum:
            return "∑"
        }
    }
}