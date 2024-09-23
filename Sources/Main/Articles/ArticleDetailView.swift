//
//  ArticleDetailView.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import SwiftUI
import Kingfisher

struct ArticleDetailView: View {
    @ObservedObject var manager: ArticleDetailManager

    let backButtonAction: () -> Void

    private let initialImageHeight: CGFloat = 300
    private let collapsedImageHeight: CGFloat = 80

    @ObservedObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }

    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = initialImageHeight - collapsedImageHeight

        if offset < -sizeOffScreen {
            let imageOffset = abs(min(-sizeOffScreen, offset))
            return imageOffset - sizeOffScreen
        }

        if offset > 0 {
            return -offset

        }

        return 0
    }

    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }

    private func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY

        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height

        return blur * 6
    }

    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY

        if currentYPos < headerImageRect.maxY {
            let minYValue: CGFloat = 50.0
            let maxYValue: CGFloat = collapsedImageHeight
            let currentYValue = currentYPos

            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue))
            let finalOffset: CGFloat = -30.0

            return 20 - (percentage * finalOffset)
        }

        return .infinity
    }

    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(manager.article.title)
                            .lineLimit(nil)
                            .lineSpacing(8)
                            .font(.inter(size: 32).weight(.semibold))
                        Spacer()
                    }
                    ArticleAuthorView(avatar: manager.article.authorAvatar,
                                      name: manager.article.authorName,
                                      date: manager.article.date)
                    Text(manager.article.content)
                        .lineLimit(nil)
                        .lineSpacing(14)
                        .font(.merriweather(size: 16))
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .offset(y: initialImageHeight)
            .background(GeometryGetter(rect: $articleContent.frame))

            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    KFImage(manager.article.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                        .blur(radius: self.getBlurRadiusForImage(geometry))
                        .clipped()
                        .background(GeometryGetter(rect: self.$headerImageRect))
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(.background)
                        .frame(width: geometry.size.width, height: 48)
                        .offset(y: 24)
                }
                .clipped()
                .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
            }
            .frame(height: initialImageHeight)
            .offset(x: 0, y:  -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
        }
        .edgesIgnoringSafeArea(.all)
        .toolbar(.hidden, for: .navigationBar, .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    backButtonAction()
                } label: {
                    Image(systemName: "arrow.left")
                }.tint(.black)
                Spacer()
                if let isBookmarked = manager.isBookmarked {
                    Button {
                        manager.flipBookmark()
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    }.tint(.black)
                }
                Button {
                    manager.seeOriginal()
                } label: {
                    Image(systemName: "arrowshape.turn.up.right")
                }.tint(.black)
            }
        }
        .sheet(isPresented: $manager.needsPremiumSheet) {
            PremiumView() {
                manager.needsPremiumSheet = false
            }
        }
    }
}

fileprivate class ViewFrame: ObservableObject {
    var startingRect: CGRect?

    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }

    init() {
        self.frame = .zero
    }
}

fileprivate struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .local))
        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}

fileprivate struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#Preview {
    ArticleDetailView(manager: ArticleDetailManager(.sample(id: "0"))) {}
}
