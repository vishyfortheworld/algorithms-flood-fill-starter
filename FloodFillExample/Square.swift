//
//  Square.swift
//  FloodFillExample
//
//  Created by Vishrut Vatsa on 22/12/2021.
//

import SwiftUI

class Square: Equatable {
    var row: Int
    var col: Int
    var isWall = false
    var moveCost = -1

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    static func ==(lhs: Square, rhs: Square) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }
}
