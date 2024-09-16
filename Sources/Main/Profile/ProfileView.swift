//
//  ProfileView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    @ObservedObject var manager: ProfileManager
    @State private var path: [Article] = []
    @State private var premiumSheetVisible = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                VStack {
                    HStack(spacing: 24) {
                        KFImage(manager.profile?.avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        VStack {
                            Text(manager.profile?.name ?? "")
                                .font(.inter(size: 24).weight(.semibold))
                        }
                        Spacer()
                    }
                    Divider()
                    HStack {
                        Text("Premium")
                            .font(.inter(size: 24).weight(.bold))
                        Spacer()
                        Button {
                            premiumSheetVisible.toggle()
                        } label: {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 116, height: 40)
                                .foregroundColor(.hex(0xD9D9D9))
                                .overlay {
                                    if manager.hasPremium ?? false {
                                        Text("Enabled")
                                            .font(.inter(size: 14).weight(.semibold))
                                    }
                                    else {
                                        Text("Subscribe")
                                            .font(.inter(size: 14).weight(.semibold))
                                    }
                                }
                        }
                        .frame(width: 92, height: 26)
                        .disabled(manager.hasPremium ?? true)
                    }
                    .padding(.vertical)
                    if !manager.bookmarks.isEmpty {
                        Divider()
                        HStack {
                            Text("Bookmarks")
                                .font(.inter(size: 24).weight(.bold))
                            Spacer()
                        }
                    }
                }
                ForEach(manager.bookmarks) { article in
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
        .sheet(isPresented: $premiumSheetVisible) {
            PremiumView() {
                premiumSheetVisible.toggle()
            }
        }
    }
}

#Preview("Premium") {
    ProfileView(manager: MockProfileManager.hasPremium)
}

#Preview("Freeloader") {
    ProfileView(manager: MockProfileManager.hasNoPremium)
}

fileprivate final class MockProfileManager: ProfileManager {
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
