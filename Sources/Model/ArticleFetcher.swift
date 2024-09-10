//
//  ArticleFetcher.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation
import OSLog
import Combine
import Reachability

final class ArticleFetcher {
    private var cancellables: [AnyCancellable] = []

    private let logger = Logger(subsystem: "NewsApp", category: "ArticleFetcher")

    private let newsApi = NewsApi()
    private let local = LocalStorage.shared

    private var networkPresent = true

    init() {
        NotificationCenter.default.publisher(for: .reachabilityChanged).sink { [unowned self] notification in
            let reachability = notification.object as! Reachability
            logger.info("Network status changed to \(reachability.connection)")
            switch reachability.connection {
            case .unavailable: networkPresent = false
            default: networkPresent = true
            }
        }.store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func fetchArticles() async throws -> [Article] {
        let articles: [Article]

        logger.debug("Fetching articles")
        if networkPresent {
            logger.debug("Network present")
            articles = try await newsApi.fetchArticles()
            Task {
                try await local.saveArticles(articles)
            }
        }
        else {
            logger.debug("No network")
            articles = try await local.retrieveArticles()
        }

        return articles
    }
}
