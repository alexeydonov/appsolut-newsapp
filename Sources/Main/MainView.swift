//
//  MainView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI

fileprivate enum Tab {
    case articles
    case profile
}

struct MainView: View {
    let userId: String
    @State private var selectedTab: Tab = .articles

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ArticleListView(source: ArticleListSource(state: .fetching))
                    .navigationTitle("NewsApp")
            }
                .tabItem { Image(systemName: "globe.asia.australia.fill") }

            NavigationStack {
                ProfileView(manager: ProfileManager(id: userId))
            }
                .tabItem { Image(systemName: "person.crop.circle") }
        }
    }
}

#Preview {
    MainView(userId: "0")
}
