//
//  PremiumView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI

struct PremiumView: View {
    @ObservedObject private var manager = SubscriptionManager()

    let closeButtonHandler: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .top) {
                    VStack() {
                        Image("premium-image")
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
                ZStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: -24) {
                        Spacer()
                        VStack(alignment: .leading, spacing: 44) {
                            VStack(spacing: 20) {
                                Text("Get the Latest News and Updates")
                                    .font(.inter(size: 32).weight(.semibold))
                                Text("NewsApp brings you the world’s best journalism, all in one place. Trusted sources, curated by editors, and personalized for you.")
                                    .font(.schibsted(size: 18))
                            }.padding()
                            VStack(spacing: 12) {
                                if let price = manager.price, let period = manager.period {
                                    Text("\(price) per \(period)")
                                }
                                else {
                                    Text("")
                                }
                                Button {
                                    manager.subscribe()
                                } label: {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(.hex(0xD32621))
                                        .frame(width: 360, height: 60)
                                        .overlay {
                                            Text("Subscribe")
                                                .font(.libre(size: 22).weight(.bold))
                                                .foregroundStyle(.white)
                                        }
                                }
                            }.padding()
                        }.background(.white).cornerRadius(24)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                Button(action: {
                    closeButtonHandler()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                })
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .presentationCompactAdaptation(.fullScreenCover)
    }
}

#Preview {
    PremiumView() {}
}
