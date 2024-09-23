//
//  Mocks.swift
//  NewsApp
//
//  Created by Alexey Donov on 20.09.2024.
//

import Foundation

final class MockAppViewState: AppViewState {
    override func startApp() {
        //
    }

    override func signIn() {
        //
    }
}

final class MockArticleListSource: ArticleListSource {
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

extension Article {
    static func sample(id: String) -> Article {
        Article(
            id: id,
            title: "Article Title",
            content: """
Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa
te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean.
""",
            url: URL(string: "https://apple.com")!,
            image: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Shaqi_jrvej.jpg/1200px-Shaqi_jrvej.jpg"),
            date: Date(),
            authorAvatar: URL(string: "https://gravatar.com/avatar/282ca84afab836f2adacaa7547ba912fa94c3be40622178fa8f1e94c96ba2cd9"),
            authorName: "Article Writer"
        )
    }
}

final class MockProfileManager: ProfileManager {
    static var hasPremium: MockProfileManager {
        MockProfileManager(hasPremium: true)
    }

    static var hasNoPremium: MockProfileManager {
        MockProfileManager(hasPremium: false)
    }

    private init(hasPremium: Bool) {
        super.init(id: "0")
        self.profile = Profile(name: "User Name",
                               avatar: URL(string: "https://gravatar.com/avatar/282ca84afab836f2adacaa7547ba912fa94c3be40622178fa8f1e94c96ba2cd9"))
        self.hasPremium = hasPremium
    }
}
