//
//  SubscriptionManager.swift
//  NewsApp
//
//  Created by Alexey Donov on 09.09.2024.
//

import Foundation
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    private let iap = IAP.shared

    private var cancellables: [AnyCancellable] = []

    @Published private(set) var price: String?
    @Published private(set) var period: String?

    init() {
        fetchPrice()
    }

    private func fetchPrice() {
        Task {
            guard let product = try await iap.product(), let sub = product.subscription else { return }

            price = product.displayPrice
            let periodValue = sub.subscriptionPeriod.value
            let periodUnit = sub.subscriptionPeriod.unit.formatted(product.subscriptionPeriodUnitFormatStyle)
            if periodValue > 1 {
                period = "\(periodValue.formatted()) \(periodUnit)"
            }
            else {
                period = periodUnit
            }
        }
    }

    func subscribe() {
        Task {
            try await iap.purchaseSubscription()
        }
    }
}
