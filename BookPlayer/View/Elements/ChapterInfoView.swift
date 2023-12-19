//
//  SwiftUIView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//
import ComposableArchitecture
import SwiftUI

struct ChapterInfoView: ViewStoreViewProtocol {
    
    var viewStore: ComposableArchitecture.ViewStore<BookFeature.State, BookFeature.Action>
    
        var body: some View {
            VStack {
                Text("Key point \(viewStore.currentChapter.chapterIndex) of \(viewStore.chapters.count)")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)

                Text(viewStore.currentChapter.title)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15, weight: .regular))
                    .lineLimit(0)
                    .frame(maxHeight: 45)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 40)
        }
}

#Preview {
    WithViewStore( Store(
        initialState: BookFeature.State(chapters: [])
    ) {
        BookFeature()
    }, observe: { $0 }) { viewStore in
        ChapterInfoView(viewStore: viewStore)
    }
}
