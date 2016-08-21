//
//  PlaySection.swift
//  Yamb
//
//  Created by Kresimir Prcela on 19/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum PlaySection: Int {
    case Header = 0
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
    case SumNumbers
    case Max
    case Min
    case SumMaxMin
    case Skala
    case Full
    case Poker
    case Yamb
    case SumSFPY
    
    func name() -> String {
        switch self {
        case .One,.Two,.Three,.Four,.Five,.Six:
            return String(rawValue)
        case .SumNumbers, .SumMaxMin, .SumSFPY:
            return "∑"
        case .Max:
            return "Max"
        case .Min:
            return "Min"
        case .Skala:
            return "Skala"
        case .Full:
            return "Full"
        case .Poker:
            return "Poker"
        case .Yamb:
            return "Yamb"
        default:
            return ""
        }
    }
}
