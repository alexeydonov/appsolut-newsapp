//
//  ArticleListView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import StoreKit

struct ArticleListView: View {
    @ObservedObject var source: ArticleListSource
    @State private var path = NavigationPath()

    var body: some View {
        switch source.state {
        case .fetching:
            ProgressView()
                .progressViewStyle(.circular)
                .onAppear {
                    source.fetchArticles()
                }

        case .error(let error):
            VStack(spacing: 50) {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.red)
                VStack(spacing: 10) {
                    Text("Error")
                        .font(.inter(size: 32).weight(.semibold))
                    Text(error.localizedDescription)
                        .font(.inter(size: 16))
                }
                Button {
                    source.fetchArticles()
                } label: {
                    Label {
                        Text("Retry")
                    } icon: {
                        Image(systemName: "arrow.circlepath")
                    }
                }
            }.padding()

        case .ready(let list):
            if list.isEmpty {
                VStack(spacing: 50) {
                    VStack(spacing: 10) {
                        Image(systemName: "network")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                        Text("Check your network connection")
                            .font(.inter(size: 20).weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        source.fetchArticles()
                    } label: {
                        Label {
                            Text("Retry")
                        } icon: {
                            Image(systemName: "arrow.circlepath")
                        }

                    }
                }
            }
            else {
                NavigationStack(path: $path) {
                    HStack(spacing: 16) {
                        ForEach(source.categories) { category in
                            Button {
                                source.selectedCategory = category
                            } label: {
                                if source.selectedCategory.id == category.id {
                                    RoundedRectangle(cornerRadius: 56)
                                        .foregroundStyle(Color.hex(0xE9EEFA))
                                        .frame(height: 32)
                                        .overlay {
                                            Text(category.title)
                                                .font(.inter(size: 14).weight(.semibold))
                                                .foregroundStyle(.black)
                                        }
                                }
                                else {
                                    RoundedRectangle(cornerRadius: 56)
                                        .foregroundStyle(Color.hex(0xE9EEFA))
                                        .frame(height: 32)
                                        .clipShape(.rect(cornerRadius: 56).stroke())
                                        .overlay {
                                            Text(category.title)
                                                .font(.inter(size: 14).weight(.semibold))
                                                .foregroundStyle(.primary)
                                        }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    List {
                        ForEach(list) { article in
                            Button {
                                path.append(article)
                            } label: {
                                ArticleListItemView(article: article)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: Article.self) { article in
                        let manager = ArticleDetailManager(article)
                        return ArticleDetailView(manager: manager) {
                            path.removeLast()
                        }
                    }
                }
            }
        }
    }
}

#Preview("Fetching") {
    ArticleListView(source: MockArticleListSource.fetching)
}

#Preview("Error") {
    ArticleListView(source: MockArticleListSource.error)
}

#Preview("Ready") {
    ArticleListView(source: MockArticleListSource.ready)
}

#Preview("Empty") {
    ArticleListView(source: MockArticleListSource.empty)
}

fileprivate class MockArticleListSource: ArticleListSource {
    static var fetching: MockArticleListSource {
        MockArticleListSource(state: .fetching)
    }

    static var error: MockArticleListSource {
        let error = NSError(domain: "Error happened :(", code: 0)
        return MockArticleListSource(state: .error(error))
    }

    static var ready: MockArticleListSource {
        var articles = [Article]()
        for i in 0..<20 {
            articles.append(.sample(id: "\(i)"))
        }
        return MockArticleListSource(state: .ready(articles))
    }

    static var empty: MockArticleListSource {
        MockArticleListSource(state: .ready([]))
    }

    override func fetchArticles() {
        //
    }
}
