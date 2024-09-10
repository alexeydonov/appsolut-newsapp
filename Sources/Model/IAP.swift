//
//  IAP.swift
//  NewsApp
//
//  Created by Alexey Donov on 09.09.2024.
//

import Foundation
import StoreKit
import Combine
import OSLog

final class IAP {
    private static let subscriptionId = "net.alexeydonov.newsapp.monthly"

    static let shared = IAP()

    private let logger = Logger(subsystem: "NewsApp", category: "IAP")

    let subscriptionStatusPublisher = CurrentValueSubject<Bool, Never>(false)

    private var transactionListener: Task<Void, Error>?

    private init() {
        startSubscriptionTracking()
    }

    deinit {
        transactionListener?.cancel()
    }

    private var cachedProduct: Product?
    func product() async throws -> Product? {
        if cachedProduct == nil {
            cachedProduct = try await Product.products(for: [Self.subscriptionId]).first
        }
        return cachedProduct
    }

    func purchaseSubscription() async throws {
        logger.debug("Starting subscription purchase")
        do {
            guard let product = try await product() else {
                throw AppError.configuration("No subscription configuration")
            }

            let result = try await product.purchase()
            logger.info("Purchase result received")

            switch result {
            case .success: break
            case .userCancelled: break
            case .pending: break
            @unknown default: throw AppError.failedPurchase("Unknown error")
            }
        } catch {
            throw error
        }
    }

    private func startSubscriptionTracking() {
        transactionListener = Task.detached { [unowned self] in
            try await AppStore.sync()
            for await update in Transaction.updates {
                if Task.isCancelled { break }
                logger.info("Transaction update received: \(update.debugDescription)")
                do {
                    let transaction = try verifyPurchase(update)
                    try await updatePurchases()
                    await transaction.finish()
                }
                catch {
                    logger.error("Transaction failed: \(error)")
                }
            }
        }
    }

    private func verifyPurchase<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw AppError.failedPurchase("Transaction is not verified")
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchases() async throws {
        for await entitlement in Transaction.currentEntitlements {
            do {
                let verifiedPurchase = try verifyPurchase(entitlement)
                switch verifiedPurchase.productType {
                case .autoRenewable:
                    if verifiedPurchase.productID == Self.subscriptionId {
                        subscriptionStatusPublisher.send(true)
                    }
                default: break
                }
            } catch {
                throw error
            }
        }
    }

}
