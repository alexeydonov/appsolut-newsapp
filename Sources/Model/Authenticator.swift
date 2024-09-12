//
//  Authenticator.swift
//  NewsApp
//
//  Created by Alexey Donov on 08.09.2024.
//

import Foundation
import UIKit
import OSLog
import Firebase
import FirebaseAuth
import GoogleSignIn

final class Authenticator {
    private let logger = Logger(subsystem: "NewsApp", category: "Authenticator")

    func restorePreviousSignIn() async throws -> String? {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            logger.debug("Restoring previous sign in")
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            return try await authenticateUser(for: user)
        }
        else {
            return nil
        }
    }

    @MainActor
    func signIn(with controller: UIViewController) async throws -> String {
        if let token = try await restorePreviousSignIn() {
            return token
        }

        logger.debug("New sign in started")
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AppError.configuration("No FirebaseID")
        }

        let configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.configuration = configuration
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: controller)
        return try await authenticateUser(for: result.user)
    }

    private func authenticateUser(for user: GIDGoogleUser) async throws -> String {
        let credential = GoogleAuthProvider.credential(withIDToken: user.idToken!.tokenString, accessToken: user.accessToken.tokenString)
        let _ = try await Auth.auth().signIn(with: credential)
        try await LocalStorage.shared.saveProfile(user)
        logger.debug("User authenticated with token \(user.idToken!.tokenString)")

        return user.idToken!.tokenString
    }
}
