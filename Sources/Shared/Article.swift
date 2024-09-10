//
//  Article.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation

struct Article: Identifiable, Hashable {
    var id: String
    var title: String
    var content: String
    var image: URL?
    var date: Date
    var authorAvatar: URL?
    var authorName: String
}
