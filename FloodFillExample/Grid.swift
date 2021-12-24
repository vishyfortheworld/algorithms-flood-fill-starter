//
//  Grid.swift
//  FloodFillExample
//
//  Created by Vishrut Vatsa on 22/12/2021.
//

import Combine
import SwiftUI

class Grid: ObservableObject {
    static let size = 20
    
    let squares: [[Square]]
    var startSquare: Square
    var endSquare: Square
    
    var queuedSquares = [Square]()
    var checkedSquares = [Square]()
    var path = [Square]()
    
    //schedules timer
    var stepper: Cancellable?
    
    init() {
        var grid = [[Square]]()
        
        for row in 0..<Grid.size {
            var cols = [Square]()
            
            for col in 0..<Grid.size {
                let square = Square(row: row, col: col)
                cols.append(square)
            }
            
            grid.append(cols)
        }
        
        squares = grid
        
        startSquare = grid[1][1]
        endSquare = grid[Grid.size - 2][Grid.size - 2]
    }
    
    func reset() {
        objectWillChange.send()
        
        for row in squares {
            for col in row {
                col.isWall = false
            }
        }
    }
    
    func clear() {
        objectWillChange.send()
        
        queuedSquares.removeAll()
        checkedSquares.removeAll()
        path.removeAll()
        
        for row in squares {
            for col in row {
                col.moveCost = -1
            }
        }
    }
    
    func randomize() {
        objectWillChange.send()
        
        for row in squares {
            for col in row {
                if col == startSquare { continue }
                if col == endSquare { continue }
                col.isWall = true
            }
        }
        
        for _ in 1...250 {
            let randomRow = Int.random(in: 0..<Grid.size)
            let randomCol = Int.random(in: 0..<Grid.size)
            squares[randomRow][randomCol].isWall = false
        }
        
        route()
    }
    
    func neighbors(for square: Square) -> [Square] {
        var result = [Square]()
        
        if (square.col > 0) {
            // check square to the left
            result.append(squares[square.row][square.col - 1])
        }
        
        if (square.col < Grid.size - 1) {
            // check square to the right
            result.append(squares[square.row][square.col + 1])
        }
        
        if (square.row > 0) {
            // check square above
            result.append(squares[square.row - 1][square.col])
        }
        
        if (square.row < Grid.size - 1) {
            // check square below
            result.append(squares[square.row + 1][square.col])
        }
        
        if (square.col > 0) {
            if (square.row > 0) {
                // check square above left
                result.append(squares[square.row - 1][square.col - 1])
            }
            
            if (square.row < Grid.size - 1) {
                // check square below left
                result.append(squares[square.row + 1][square.col - 1])
            }
        }
        
        if (square.col < Grid.size - 1) {
            if (square.row > 0) {
                // check square above right
                result.append(squares[square.row - 1][square.col + 1])
            }
            
            if (square.row < Grid.size - 1) {
                // check square below right
                result.append(squares[square.row + 1][square.col + 1])
            }
        }
        
        return result
    }
    
    func placeWall(atRow row: Int, col: Int) {
        guard squares[row][col].isWall == false else { return }
        
        objectWillChange.send()
        squares[row][col].isWall = true
    }
    
    func removeWall(atRow row: Int, col: Int) {
        guard squares[row][col].isWall == true else { return }
        
        objectWillChange.send()
        squares[row][col].isWall = false
    }
    
    func color(for square: Square) -> Color {
        if square == startSquare {
            return .blue
        } else if square == endSquare {
            return .green
        } else if square.isWall {
            return .black
        } else if path.contains(square){
            return .white
        } else if queuedSquares.contains(square){
            return .orange
        } else if checkedSquares.contains(square) {
            return Color.orange.opacity(0.5)
        } else {
            return .gray
        }
    }
    
    func route() {
        
        //clear any existing route data
        checkedSquares.removeAll()
        queuedSquares.removeAll()
        path.removeAll()
        
        //set all squares back to their default state
        for row in squares {
            for col in row {
                col.moveCost = -1
            }
        }
        
        // add initial square to the queue
        queuedSquares.append(startSquare)
        startSquare.moveCost = 0
        
        //keep stepping through the route algo until nothing to check
        while queuedSquares.isEmpty == false {
            stepRoute()
        }
        
    }
    
    func floodFill(from square: Square) {
        //find all squares next to this square
        let checkSquares = neighbors(for: square)
        
        for checkSquare in checkSquares {
            //ignore walls
            guard checkSquare.isWall == false else {continue}
            
            //if this is a move worth checking
            if checkSquare.moveCost == -1 || square.moveCost + 1 < checkSquare.moveCost {
                
                //update its move cost to be one higher than our starting square's cosr
                checkSquare.moveCost = square.moveCost + 1
                
                //add it to teh  list of squares to flood fill from
                queuedSquares.append(checkSquare)
            }
        }
    }
    
    func stepRoute() {
        // notify swiftUi that it needs to reinvoke its view body shortly
        objectWillChange.send()
        
        //move the first square to be checked
        let square = queuedSquares.removeFirst()
        checkedSquares.append(square)
        if square == endSquare {
            //we found a route
            selectRoute()
            return
        }
        
        // queue up any possible squares near this one
        floodFill(from: square)
        if queuedSquares.isEmpty {
            // finished searching all options
            selectRoute()
        }
    }
    
    func selectRoute() {
        guard endSquare.moveCost != -1 else {
            print("No route available")
            return
        }
        
        path.append(endSquare)
        var current = endSquare
        
        while current != startSquare {
            // find all neighbours
            for neighbor in neighbors(for: current)
            {
                //skip ignored squares
                guard neighbor.moveCost != -1 else {continue}
                
                //if neighbor has lower cost than current move cost add it to the path and mve there
                if neighbor.moveCost < current.moveCost {
                    
                    path.append(neighbor)
                    current = neighbor
                    
                    // break out of the inner loop so we can scan for neighbior from current square
                    break
                }
                
                
                
            }
        }
    }
}
