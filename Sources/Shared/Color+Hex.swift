//
//  Color+Hex.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI

extension Color {
    static func hex(_ hex: Int) -> Color {
        return self.init(
            red:   Double((hex & 0x00ff0000) >> 16) / 255.0,
            green: Double((hex & 0x0000ff00) >> 8) / 255.0,
            blue:  Double((hex & 0x000000ff)) / 255.0
        )
    }
}
