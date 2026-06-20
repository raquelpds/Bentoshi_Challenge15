//
//  WorkspaceColorPallete.swift
//  Bentoshi
//
//  Created by Rebeca Maria de Morais Guimães on 19/06/26.
//

import Foundation
import SwiftUI

struct WorkspaceColorPalette {

    static func color(
        for color: WorkspaceColor,
        scheme: ColorScheme
    ) -> Color {

        let isDark = scheme == .dark

        switch color {

        case .pink:
            return Color(hex: isDark ? "#C27085" : "#C27085")

        case .blueLight:
            return Color(hex: isDark ? "#689BB9" : "#689BB9")

        case .blueDark:
            return Color(hex: isDark ? "#516AA2" : "#516AA2")

        case .yellow:
            return Color(hex: isDark ? "#E8D192" : "#E8D192")

        case .purple:
            return Color(hex: isDark ? "#845B95" : "#845B95")

        case .gray:
            return Color(hex: isDark ? "#848484" : "#848484")

        case .green:
            return Color(hex: isDark ? "#9EBA7E" : "#9EBA7E")
            
        case .orange:
            return Color(hex: isDark ? "#D09668" : "#D09668")
            
        case .red:
            return Color(hex: isDark ? "#C0605D" : "#C0605D")
        }
    }
}

