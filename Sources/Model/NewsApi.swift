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

fileprivate struct NewsSource: Decodable {
    var id: String?
    var name: String?
}

fileprivate struct NewsArticle: Decodable {
    var source: NewsSource
    var author: String?
    var title: String
    var url: URL
    var urlToImage: URL?
    var publishedAt: Date
    var content: String

    var article: Article {
        Article(id: UUID().uuidString,
                title: title,
                content: content,
                url: url,
                image: urlToImage,
                date: publishedAt,
                authorAvatar: nil,
                authorName: author ?? (source.name ?? "Unknown author"))
    }
}

fileprivate struct NewsApiProperties: Decodable {
    var key: String
}

final class NewsApi {
    struct Category: Identifiable {
        var id: String
        var title: String

        static var all: [Category] {
            ["travel", "technology", "business"].map { Category(id: $0, title: $0.capitalized) }
        }
    }

    private let logger = Logger(subsystem: "NewsApp", category: "NewsApi")

    private var key: String?

    private lazy var posixDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(abbreviation: "GMT")

        return formatter
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(posixDateFormatter)

        return decoder
    }()

    init() {
        guard let url = Bundle.main.url(forResource: "NewsApi-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let properties = try? PropertyListDecoder().decode(NewsApiProperties.self, from: data) else { return }

        self.key = properties.key
    }

    func fetchArticles(category: Category? = nil) async throws -> [Article] {
        logger.debug("Fetching articles from network")
        guard let key = self.key else {
            throw AppError.configuration("No newsapi.org API key")
        }

        var components = URLComponents(string: "https://newsapi.org/v2/everything")!
        if let category {
            components.queryItems = [URLQueryItem(name: "q", value: category.id)]
        }
        var request = URLRequest(url: components.url!)
        request.addValue(key, forHTTPHeaderField: "X-Api-Key")
        let data = try await URLSession.shared.data(for: request)
        let response = try decoder.decode(NewsResponse.self, from: data.0)

        return response.articles.map(\.article)
    }
}
