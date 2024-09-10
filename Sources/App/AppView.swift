//
//  AppView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI

struct AppView: View {
    @ObservedObject var appState: AppViewState

    var body: some View {
        switch appState.state {
        case .splash: 
            SplashView().onAppear {
                appState.startApp()
            }

        case .welcome: 
            WelcomeView()
                .environmentObject(appState)

        case .signedIn(let token):
            MainView(userId: token)
        }
    }
}

#Preview("Splash") {
    AppView(appState: MockAppViewState(state: .splash))
}

#Preview("Welcome") {
    AppView(appState: MockAppViewState(state: .welcome))
}

fileprivate final class MockAppViewState: AppViewState {
    override func startApp() {
        //
    }

    override func signIn() {
        //
    }
}
