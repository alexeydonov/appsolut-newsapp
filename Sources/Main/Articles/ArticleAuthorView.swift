//
//  ArticleAuthorView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import Kingfisher

struct ArticleAuthorView: View {
    var avatar: URL?
    var name: String
    var date: Date

    var body: some View {
        HStack(spacing: 4) {
            if let url = avatar {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            }
            else {
                Image(systemName: "person")
                    .foregroundStyle(.primary)
            }
            Text(name).font(.inter(size: 12))
            Text("∙").font(.inter(size: 12))
            Text(DateFormatter.articleList.string(from: date)).font(.inter(size: 12))
        }.foregroundColor(.secondary)
    }
}

#Preview {
    ArticleAuthorView(avatar: URL(string: "https://gravatar.com/avatar/282ca84afab836f2adacaa7547ba912fa94c3be40622178fa8f1e94c96ba2cd9"),
                      name: "Article Writer",
                      date: Date())
}
