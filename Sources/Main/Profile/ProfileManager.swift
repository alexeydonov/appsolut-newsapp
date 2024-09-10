//
//  ProfileManager.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import Foundation
import Combine

@MainActor
class ProfileManager: ObservableObject {
    let id: String

    @Published var profile: Profile?
    @Published var hasPremium: Bool?
    @Published var bookmarks: [Article] = []

    private var cancellables: [AnyCancellable] = []

    init(id: String) {
        self.id = id
        startTracking()
    }

    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }

    private func startTracking() {
        LocalStorage.shared.bookmarkListPublisher.sink { [unowned self] articles in
            bookmarks = articles
        }.store(in: &cancellables)
        IAP.shared.subscriptionStatusPublisher.sink { [unowned self] status in
            hasPremium = status
        }.store(in: &cancellables)
        Task {
            profile = try await LocalStorage.shared.fetchProfile(id: id)
        }
    }
}
