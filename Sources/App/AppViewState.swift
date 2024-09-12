//
//  AppViewState.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import OSLog

enum AppState {
    case splash
    case welcome
    case signedIn(String)
}

@MainActor
class AppViewState: ObservableObject {
    @Published
    private(set) var state: AppState

    private let authenticator = Authenticator()

    private let logger = Logger(subsystem: "NewsApp", category: "AppViewState")

    init(state: AppState) {
        self.state = state
    }

    func startApp() {
        logger.debug("Starting app")
        Task {
            do {
                if let credential = try await authenticator.restorePreviousSignIn() {
                    self.state = .signedIn(credential)
                }
                else {
                    self.state = .welcome
                }
            }
            catch {
                logger.info("Error while restoring sign in: \(error)")
                self.state = .welcome
            }
        }
    }

    func signIn() {
        logger.debug("User initiated sign in")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

        Task {
            do {
                let token = try await authenticator.signIn(with: rootViewController)
                self.state = .signedIn(token)
            }
            catch {
                logger.info("Error while signing in: \(error)")
                self.state = .welcome
            }
        }
    }

}
