//
//  DateFormatter.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation

extension DateFormatter {
    static let articleList = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter
    }()
}
