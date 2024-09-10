//
//  NewsAppApp.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import Firebase
import Reachability

@main
struct NewsApp: App {
    let reachability: Reachability?

    var body: some Scene {
        WindowGroup {
            AppView(appState: AppViewState(state: .splash))
        }
    }

    init() {
        reachability = try? Reachability()
        try? reachability?.startNotifier()
        setupAuthentication()
    }

    private func setupAuthentication() {
        FirebaseApp.configure()
    }
}
