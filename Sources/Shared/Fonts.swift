//
//  Fonts.swift
//  NewsApp
//
//  Created by Alexey Donov on 08.09.2024.
//

import SwiftUI

extension Font {
    static func inter(size: Int) -> Font {
        Font.custom("Inter-Regular", size: CGFloat(size))
    }

    static func libre(size: Int) -> Font {
        Font.custom("LibreFranklinRoman", size: CGFloat(size))
    }

    static func merriweather(size: Int) -> Font {
        Font.custom("Merriweather-Regular", size: CGFloat(size))
    }

    static func schibsted(size: Int) -> Font {
        Font.custom("SchibstedGrotesk", size: CGFloat(size))
    }
}
