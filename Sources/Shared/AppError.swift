//
//  AppError.swift
//  NewsApp
//
//  Created by Alexey Donov on 08.09.2024.
//

import Foundation

enum AppError: Error {
    case configuration(String)
    case network
    case failedPurchase(String)

    var localizedDescription: String {
        switch self {
        case .configuration(let message): return "Configuration error: \(message)"
        case .network: return "No network connection"
        case .failedPurchase(let message): return message
        }
    }
}
