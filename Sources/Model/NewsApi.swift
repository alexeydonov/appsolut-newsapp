//
//  NewsApi.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation
import OSLog

fileprivate struct NewsResponse: Decodable {
    var status: String
    var totalResults: Int
    var articles: [NewsArticle]
}

fileprivate struct NewsArticle: Decodable {
    var author: String
    var title: String
    var urlToImage: URL
    var publishedAt: Date
    var content: String

    var article: Article {
        Article(id: UUID().uuidString,
                title: title,
                content: content,
                image: urlToImage,
                date: publishedAt,
                authorAvatar: nil,
                authorName: author)
    }
}

fileprivate struct NewsApiProperties: Decodable {
    var key: String
}

final class NewsApi {
    private let logger = Logger(subsystem: "NewsApp", category: "NewsApi")

    private var key: String?

    init() {
        guard let url = Bundle.main.url(forResource: "NewsApi-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let properties = try? PropertyListDecoder().decode(NewsApiProperties.self, from: data) else { return }

        self.key = properties.key
    }

    func fetchArticles() async throws -> [Article] {
        logger.debug("Fetching articles from network")
        guard let key = self.key else {
            throw AppError.configuration("No newsapi.org API key")
        }

        var request = URLRequest(url: URL(string: "https://newsapi.org/v2/everything")!)
        request.addValue(key, forHTTPHeaderField: "X-Api-Key")
        let data = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(NewsResponse.self, from: data.0)

        return response.articles.map(\.article)
    }
}
