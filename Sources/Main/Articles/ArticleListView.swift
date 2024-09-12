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
            VStack(spacing: 20) {
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
                Button(action: {
                    source.fetchArticles()
                }, label: {
                    Label(
                        title: { Text("Retry") },
                        icon: { Image(systemName: "arrow.circlepath") }
                    )
                })
            }.padding()

        case .ready(let list):
            NavigationStack(path: $path) {
                HStack(spacing: 16) {
                    ForEach(source.categories) { category in
                        Button {
                            source.selectedCategory = category
                        } label: {
                            RoundedRectangle(cornerRadius: 56)
                                .foregroundStyle(category.id == source.selectedCategory.id ? Color.hex(0xE9EEFA) : .white)
                                .frame(height: 32)
                                .overlay {
                                    Text(category.title)
                                        .font(.inter(size: 14).weight(.semibold))
                                        .foregroundStyle(.black)
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

#Preview("Fetching") {
    ArticleListView(source: MockArticleListSource.fetching)
}

#Preview("Error") {
    ArticleListView(source: MockArticleListSource.error)
}

#Preview("Ready") {
    ArticleListView(source: MockArticleListSource.ready)
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

    override func fetchArticles() {
        //
    }
}
