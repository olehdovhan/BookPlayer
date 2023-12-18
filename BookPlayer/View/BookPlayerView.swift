//
//  ContentView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct BookPlayerView: View {
    var body: some View {
        VStack {
            ZStack {
                Color.backgroundColor
                VStack {
                    CoverImageView(coverImage: Image(systemName: "book"))
                    ChapterInfoView()
                    SliderView()
                    SpeedChangerView()
                    AudioControlsView()
                    DummyToggleView()
                }
                .padding(0)
                .foregroundColor(.black)
                
            }
        }
        .padding()
    }
}

#Preview {
    BookPlayerView()
}

extension Color {
    static let backgroundColor = Color("backgroundColor")
}
