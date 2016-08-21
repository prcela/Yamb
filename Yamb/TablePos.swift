//
//  TablePos.swift
//  Yamb
//
//  Created by Kresimir Prcela on 21/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

struct TablePos {
    var rowIdx: Int=0
    var colIdx: Int=0
}

extension TablePos: Equatable {}

func ==(lhs: TablePos, rhs: TablePos) -> Bool {
    return lhs.colIdx == rhs.colIdx && lhs.rowIdx == rhs.rowIdx
}
