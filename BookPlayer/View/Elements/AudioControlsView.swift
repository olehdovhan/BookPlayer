//
//  AudioControlsView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//
import ComposableArchitecture
import SwiftUI

struct AudioControlsView: ViewStoreViewProtocol {
    
    var viewStore: ComposableArchitecture.ViewStore<BookFeature.State, BookFeature.Action>

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                viewStore.send(.previousChapter)
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundColor(viewStore.currentChapterIndex == 0 ? .gray : .black)
            }
            .disabled(viewStore.currentChapterIndex == 0)
            
            Spacer()
            Button {
                viewStore.send(.backward(seconds: 5.0))
            } label: {
                Image(systemName: "gobackward.5")
            }
            
            Spacer()
            
            Button {
                viewStore.send(.playButtonTapped)
            } label: {
                Image(systemName: viewStore.mode.is(\.playing) ? "pause.fill" : "play.fill")
                    .font(.system(size: 46))
                    .frame(width: 50,height: 50)
            }
            
            Spacer()
            
            Button {
                viewStore.send(.forward(seconds:10.0))
            } label: {
                Image(systemName: "goforward.10")
            }
            
            Spacer()
            
            Button {
                viewStore.send(.nextChapter)
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundColor(viewStore.currentChapterIndex == (viewStore.chapters.count - 1) ? .gray : .black)
            }
            .disabled(viewStore.currentChapterIndex == (viewStore.chapters.count - 1))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 60)
        .font(.system(size: 30))
        .foregroundColor(.black)
    }
}

#Preview {
    WithViewStore( Store(
        initialState: BookFeature.State(chapters: [])
    ) {
        BookFeature()
    }, observe: { $0 }) { viewStore in
        AudioControlsView(viewStore: viewStore)
    }
}
