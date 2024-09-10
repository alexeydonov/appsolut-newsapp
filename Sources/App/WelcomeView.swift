//
//  WelcomeView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import GoogleSignInSwift

struct WelcomeView: View {
    @EnvironmentObject var authenticator: AppViewState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.hex(0x2249D4), .hex(0xE9EEFA)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea(.all, edges: [.top])
            VStack(alignment: .leading, spacing: -24) {
                Spacer()
                Image("welcome-image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                ZStack {
                    VStack(alignment: .leading, spacing: 50) {
                        VStack(spacing: 20) {
                            Text("Get the Latest News and Updates")
                                .font(.inter(size: 32).weight(.semibold))
                            Text("NewsApp brings you the world’s best journalism, all in one place. Trusted sources, curated by editors, and personalized for you.")
                                .font(.schibsted(size: 18))
                        }
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel.customized) {
                            authenticator.signIn()
                        }
                    }.padding(24)
                }.background(.white).cornerRadius(24)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
