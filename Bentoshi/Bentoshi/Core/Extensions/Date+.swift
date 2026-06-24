//
//  Date+.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 24/06/26.
//

import Foundation

extension Date {
    func formatToStringFullDate() -> String {
        return self.formatted(
            .dateTime
                .locale(Locale(identifier: "pt_BR"))
                .day()
                .month(.wide)
                .year()
        )
    }
}
