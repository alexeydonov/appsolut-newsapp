//
//  LocalStorage.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation
import OSLog
import Combine
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

final class LocalStorage {
    private enum Collection {
        static let profiles = "profiles"
        static let articles = "articles"
        static let bookmarks = "bookmarks"
    }

    static let shared = LocalStorage()

    private let logger = Logger(subsystem: "NewsApp", category: "LocalStorage")

    private let db = Firestore.firestore()

    private var bookmarkCollectionListener: ListenerRegistration?
    let bookmarkListPublisher = CurrentValueSubject<[Article], Never>([])

    private init() {
        startBookmarkListener()
    }

    deinit {
        bookmarkCollectionListener?.remove()
    }

    private func startBookmarkListener() {
        guard bookmarkCollectionListener == nil else { return }

        bookmarkCollectionListener = db.collection(Collection.bookmarks).addSnapshotListener { [unowned self] snapshot, error in
            if let documents = snapshot?.documents {
                bookmarkListPublisher.send(documents.map { $0.data() }.map(Article.init(from:)))
            }
        }
    }

    func saveProfile(_ profile: GIDGoogleUser) async throws {
        try await db.collection(Collection.profiles)
            .document(profile.idToken!.tokenString)
            .setData([
                "name": profile.profile!.name,
                "avatar": profile.profile!.imageURL(withDimension: 120)?.absoluteString as Any
            ])
    }

    func fetchProfile(id: String) async throws -> Profile? {
        return try await db.collection(Collection.profiles)
            .document(id)
            .getDocument()
            .data()
            .map(Profile.init(from:))
    }

    func saveArticles(_ articles: [Article], for category: NewsApi.Category) async throws {
        logger.debug("Removing old articles")
        try await db.collection(Collection.articles)
            .getDocuments()
            .documents
            .map { $0.documentID }
            .forEach { id in
                db.collection(Collection.articles)
                    .document(id)
                    .delete()
            }
        logger.debug("Saving \(articles.count) new articles in \(category.title) category")
        for article in articles {
            var data = article.data
            data["category"] = category.id
            try await db.collection(Collection.articles)
                .document(article.id)
                .setData(data)
        }
    }

    func retrieveArticles(in category: NewsApi.Category) async throws -> [Article] {
        logger.debug("Fetching articles from local storage")
        return try await db.collection(Collection.articles)
            .whereField("category", isEqualTo: category.id)
            .order(by: "date", descending: true)
            .getDocuments()
            .documents
            .map { $0.data() }
            .map(Article.init(from:))
    }

    func fetchBookmarks() async throws -> [Article] {
        try await db.collection(Collection.bookmarks)
            .getDocuments()
            .documents
            .map { $0.data() }
            .map(Article.init(from:))
    }

    func checkBookmark(_ id: String) async -> Bool {
        do {
            return try await db.collection(Collection.bookmarks).document(id).getDocument().exists
        }
        catch {
            return false
        }
    }

    func addBookmark(_ article: Article) async throws {
        try await db.collection(Collection.bookmarks)
            .document(article.id)
            .setData(article.data)
    }

    func removeBookmark(id: String) async throws {
        try await db.collection(Collection.bookmarks)
            .document(id)
            .delete()
    }
}

fileprivate extension Article {
    init(from data: [String : Any]) {
        self.init(id: data["id"] as! String,
                  title: data["title"] as! String,
                  content: data["content"] as! String,
                  url: URL(string: data["url"] as! String)!,
                  image: (data["image"] as? String).flatMap { URL(string: $0)! },
                  date: (data["date"] as! Timestamp).dateValue(),
                  authorAvatar: (data["authorAvatar"] as? String).flatMap { URL(string: $0) },
                  authorName: data["authorName"] as! String)
    }

    var data: [String : Any] {
        [
            "id": self.id,
            "title": self.title,
            "content": self.content,
            "url": self.url.absoluteString,
            "image": self.image?.absoluteString as Any,
            "date": self.date,
            "authorAvatar": self.authorAvatar?.absoluteString as Any,
            "authorName": self.authorName
        ]
    }
}

fileprivate extension Profile {
    init(from data: [String : Any]) {
        self.init(name: data["name"] as! String,
                  avatar: (data["avatar"] as! String?).flatMap { URL(string: $0) })
    }
}
