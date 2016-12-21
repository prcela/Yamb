//
//  PlaySection.swift
//  Yamb
//
//  Created by Kresimir Prcela on 19/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum TableRow: Int {
    case header = 0
    case one
    case two
    case three
    case four
    case five
    case six
    case sumNumbers
    case max
    case min
    case sumMaxMin
    case skala
    case full
    case poker
    case yamb
    case sumSFPY
    
    func name() -> String {
        switch self {
        case .one,.two,.three,.four,.five,.six:
            return String(rawValue)
        case .sumNumbers, .sumMaxMin, .sumSFPY:
            return "∑"
        case .max:
            return "Max"
        case .min:
            return "Min"
        case .skala:
            return lstr("Straight")
        case .full:
            return "Full"
        case .poker:
            return "Poker"
        case .yamb:
            return "Yamb"
        default:
            return ""
        }
    }
}
