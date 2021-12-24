//
//  ContentView.swift
//  FloodFillExample
//
//  Created by Vishrut Vatsa on 22/12/2021.
//

import Combine
import SwiftUI

struct ContentView: View {
    enum DrawingMode {
        case none, drawing, removing
    }

    @ObservedObject var grid = Grid()
    @State private var drawingMode = DrawingMode.none

    let squareSize: CGFloat = 30

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Find Route", action: grid.route)
                Button("Clear Route", action: grid.clear)
                Button("Clear Walls", action: grid.reset)
                Button("Randomize", action: grid.randomize)
            }
            .padding()

            VStack(spacing: 0) {
                ForEach(0..<Grid.size) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<Grid.size) { col in
                            let square = grid.squares[row][col]

                            ZStack {
                                Rectangle()
                                    .fill(grid.color(for: square))

                                if square.isWall == false {
                                    Text(String(square.moveCost))
                                }
                            }
                            .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        let row = Int(value.location.y / squareSize)
                        let col = Int(value.location.x / squareSize)
                        let square = grid.squares[row][col]

                        if drawingMode == .none {
                            if square.isWall {
                                drawingMode = .removing
                            } else {
                                drawingMode = .drawing
                            }
                        }

                        if drawingMode == .drawing {
                            grid.placeWall(atRow: row, col: col)
                        } else {
                            grid.removeWall(atRow: row, col: col)
                        }
                    }
                    .onEnded { value in
                        drawingMode = .none
                    }
            )
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
