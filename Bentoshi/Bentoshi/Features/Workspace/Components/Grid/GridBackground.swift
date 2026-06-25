//
//  GridBackground.swift
//  Bentoshi
//
//  Created by Raquel Souza on 23/06/26.
//

import SwiftUI

struct GridBackground: View {

    let rows: Int
    let columns: Int
    let cellSize: CGFloat = 60

    var body: some View {

        Canvas { context, size in

            var path = Path()

            for row in 0...rows {

                let y = CGFloat(row) * cellSize

                path.move(to: CGPoint(x: 0, y: y))
                path.addLine (to: CGPoint(x: CGFloat(columns) * cellSize, y: y))
            }

            for column in 0...columns {

                let x = CGFloat(column) * cellSize

                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x,y: CGFloat(rows) * cellSize))
            }

            context.stroke(path, with: .color(.gray.opacity(0.3)))
        }
        .frame( width: CGFloat(columns) * cellSize, height: CGFloat(rows) * cellSize)
    }
}
