//
//  ContentView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import ComposableArchitecture
import SwiftUI

protocol ViewStoreViewProtocol: View {
    var viewStore: ViewStore<BookFeature.State, BookFeature.Action> { get set }
}

struct BookPlayerView: View {
    
    let store: StoreOf<BookFeature>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
                ZStack {
                    Color.backgroundColor.ignoresSafeArea(.all)
                    VStack {
                        DismissButton { dismiss() }
                        CoverImageView(coverImage: viewStore.coverImage)
                        ChapterInfoView(viewStore: viewStore)
                        SliderView(viewStore: viewStore)
                        SpeedChangerView(viewStore: viewStore)
                        AudioControlsView(viewStore: viewStore)
                        DummyToggleView()
                    }
                    .padding(0)
                    .foregroundColor(.black)
     
                }
                .alert(store: self.store.scope(state: \.$alert, action: \.alert))
                .onDisappear {
                    viewStore.send(.stopPlayer)
                }
        }
    }

}

#Preview {
    BookPlayerView(store: Store(
        initialState: BookFeature.State( chapters: Chapter.mock)
    ) {
        BookFeature()
    })
}

extension Color {
    static let backgroundColor = Color("backgroundColor")
}
