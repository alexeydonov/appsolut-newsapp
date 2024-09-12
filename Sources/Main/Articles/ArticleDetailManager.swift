//
//  ArticleDetailManager.swift
//  NewsApp
//
//  Created by Alexey Donov on 08.09.2024.
//

import Foundation
import Combine
import UIKit

@MainActor
class ArticleDetailManager: ObservableObject {
    @Published var article: Article
    @Published var isBookmarked: Bool?

    private let storage = LocalStorage.shared

    private var cancellables: [AnyCancellable] = []

    @Published var needsPremiumSheet = false
    private var hasPremium = false {
        didSet {
            updatePremiumSheet()
        }
    }
    private var premiumSheetRequested = false {
        didSet {
            updatePremiumSheet()
        }
    }

    private func updatePremiumSheet() {
        needsPremiumSheet = !hasPremium && premiumSheetRequested
    }

    init(_ article: Article) {
        self.article = article

        startSubscriptionTracking()
        Task {
            hasPremium = try await IAP.shared.checkSubscription()
            isBookmarked = await storage.checkBookmark(article.id)
        }
    }

    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }

    private func startSubscriptionTracking() {
        IAP.shared.subscriptionStatusPublisher.sink { [unowned self] status in
            hasPremium = status
        }.store(in: &cancellables)
    }

    func flipBookmark() {
        guard hasPremium else {
            premiumSheetRequested = true
            return
        }

        guard let isBookmarked else { return }

        Task {
            if isBookmarked {
                try await storage.removeBookmark(id: article.id)
            }
            else {
                try await storage.addBookmark(article)
            }
            self.isBookmarked = !isBookmarked
        }
    }

    func seeOriginal() {
        guard hasPremium else {
            premiumSheetRequested = true
            return
        }

        UIApplication.shared.open(article.url)
    }
}
