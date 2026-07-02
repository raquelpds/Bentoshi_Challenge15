//
//  ArtefactColorPallete.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct ArtefactColorPalette {

    static func color(
        for type: ArtefactType,
        workspaceBaseColor: WorkspaceColor,
        scheme: ColorScheme
    ) -> Color {

        let palette = palette(for: workspaceBaseColor, scheme: scheme)

        switch type {
        case .link:
            return Color(hex: palette.link)

        case .archive:
            return Color(hex: palette.archive)

        case .text:
            return Color(hex: palette.text)
        }
    }
}

private extension ArtefactColorPalette {

    struct Palette {
        let link: String
        let archive: String
        let text: String
    }

    static func palette(for color: WorkspaceColor, scheme: ColorScheme) -> Palette {

        let isDark = scheme == .dark
        
        switch color {

        case .red:
            return Palette(
                link: isDark ? "#D3A3A2" : "#D3A3A2",
                archive: isDark ? "#C46E6B" : "#C46E6B",
                text: isDark ? "#DDC5C5" : "#DDC5C5"
            )

        case .orange:
            return Palette(
                link: isDark ? "#DBBFA7" : "#DBBFA7",
                archive: isDark ? "#D09668" : "#D09668",
                text: isDark ? "#E1D3C7" : "#E1D3C7"
            )

        case .blueDark:
            return Palette(
                link: isDark ? "#9CA8C5" : "#9CA8C5",
                archive: isDark ? "#6077A9" : "#6077A9",
                text: isDark ? "#C1C8D6" : "#C1C8D6"
            )

        case .blueLight:
            return Palette(
                link: isDark ? "#A7C1D0" : "#A7C1D0",
                archive: isDark ? "#75A3BE" : "#75A3BE",
                text: isDark ? "#C7D4DB" : "#C7D4DB"
            )

        case .green:
            return Palette(
                link: isDark ? "#BFD0AD" : "#BFD0AD",
                archive: isDark ? "#A5BF88" : "#A5BF88",
                text: isDark ? "#D5DCCD" : "#D5DCCD"
            )
            
        case .pink:
            return Palette(
                link: isDark ? "#D5ABB6" : "#D5ABB6",
                archive: isDark ? "#C67C8F" : "#C67C8F",
                text: isDark ? "#DEC9CF" : "#DEC9CF"
            )

        case .yellow:
            return Palette(
                link: isDark ? "#E7DCBD" : "#E7DCBD",
                archive: isDark ? "#E8D39B" : "#E8D39B",
                text: isDark ? "#E7E1D2" : "#E7E1D2"
            )

        case .gray:
            return Palette(
                link: isDark ? "#B5B5B5" : "#B5B5B5",
                archive: isDark ? "#8E8E8E" : "#8E8E8E",
                text: isDark ? "#CECECE" : "#CECECE"
            )

        case .purple:
            return Palette(
                link: isDark ? "#B5A1BE" : "#B5A1BE",
                archive: isDark ? "#8E699D" : "#8E699D",
                text: isDark ? "#CEC4D3" : "#CEC4D3"
            )
        }
    }
}
