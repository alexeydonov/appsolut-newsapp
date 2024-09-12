//
//  ArticleListSource.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation
import Combine

enum ArticleListSourceState {
    case fetching
    case error(Error)
    case ready([Article])
}

@MainActor
class ArticleListSource: ObservableObject {
    @Published private(set) var state: ArticleListSourceState

    private let fetcher = ArticleFetcher()

    @Published var selectedCategory = NewsApi.Category.all.first! {
        didSet {
            fetchArticles()
        }
    }
    @Published var categories: [NewsApi.Category] = {
        NewsApi.Category.all
    }()

    init(state: ArticleListSourceState) {
        self.state = state
    }

    func fetchArticles() {
        state = .fetching

        Task {
            do {
                let articles = try await fetcher.fetchArticles(in: selectedCategory)
                state = .ready(articles)
            } catch {
                state = .error(error)
            }
        }
    }
}
