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
    
    @State private var chapterNumber = 0
    
    var totalChaptersCount = 3
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: { }) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundColor(chapterNumber == 0 ? .gray : .black)
            }
            .disabled(chapterNumber == 0)
            
            Spacer()
            Button(action: { }) {
                Image(systemName: "gobackward.5")
            }
            
            Spacer()
            
            Button(action: {
                viewStore.send(.playButtonTapped)
            }) {
                Image(systemName: viewStore.mode.is(\.playing) ? "pause.fill" : "play.fill")
                    .font(.system(size: 46))
                    .frame(width: 50,height: 50)
            }
            
            Spacer()
            
            Button(action: { }) {
                Image(systemName: "goforward.10")
            }
            
            Spacer()
            
            Button(action: {
                chapterNumber += 1
            }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundColor(chapterNumber == (totalChaptersCount - 1) ? .gray : .black)
            }
            .disabled(chapterNumber == (totalChaptersCount - 1))
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
