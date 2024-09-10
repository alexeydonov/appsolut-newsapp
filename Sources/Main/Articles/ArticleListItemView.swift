//
//  ArticleListItemView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import Kingfisher

struct ArticleListItemView: View {
    var article: Article

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(article.title)
                    .font(.inter(size: 18).weight(.semibold))
                    .lineLimit(2)
                ArticleAuthorView(avatar: article.authorAvatar,
                                  name: article.authorName,
                                  date: article.date)
            }
            Spacer()
            if let image = article.image {
                KFImage(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 112, height: 80)
                    .cornerRadius(8)
            }
            else {
                Image(systemName: "photo.artframe")
                    .resizable()
                    .frame(width: 112, height: 80)
                    .font(.system(size: 122))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    ArticleListItemView(article: Article.sample(id: "0"))
}
