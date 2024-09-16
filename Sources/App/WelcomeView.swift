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
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [.hex(0x2249D4), .hex(0xE9EEFA)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea(.all, edges: [.top])
            Rectangle()
                .frame(height: 25)
                .foregroundStyle(.background)
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
                        HStack {
                            Spacer()
                            GoogleSignInButton {
                                authenticator.signIn()
                            }
                            .frame(width: 240, height: 66)
                            .overlay {
                                ZStack {
                                    Color.hex(0xEEF1F4)
                                    Label {
                                        Text("Sign in with Google")
                                            .font(.poppins(size: 16).weight(.semibold))
                                            .foregroundStyle(.black)
                                    } icon: {
                                        Image("google-icon")
                                    }
                                }
                                .frame(width: 248, height: 66)
                            }
                            Spacer()
                        }
                    }
                    .padding(24)
                }
                .background(.background)
                .cornerRadius(24)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
