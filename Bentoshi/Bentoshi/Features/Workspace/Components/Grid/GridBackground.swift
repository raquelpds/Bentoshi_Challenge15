//
//  GridBackground.swift
//  Bentoshi
//
//  Created by Raquel Souza on 23/06/26.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct GridBackground: View {

    let rows: Int
    let columns: Int
    let cellSize: CGFloat

    private let dotSize: CGFloat = 3
    private let dotSpacing: CGFloat = 32

    private let dotColor = Color(
        red: 230 / 255,
        green: 230 / 255,
        blue: 230 / 255
    )

    var body: some View {
        let width = CGFloat(columns) * cellSize
        let height = CGFloat(rows) * cellSize

        Canvas { context, size in
            var y: CGFloat = dotSize / 2

            while y <= height - dotSize / 2 {
                var x: CGFloat = dotSize / 2

                while x <= width - dotSize / 2 {
                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )

                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(dotColor)
                    )

                    x += dotSpacing
                }

                y += dotSpacing
            }
        }
        .frame(
            width: width,
            height: height
        )
    }
}
