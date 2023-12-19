//
//  SpeedChangerView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//
import ComposableArchitecture
import SwiftUI

struct SpeedChangerView:  ViewStoreViewProtocol {
    
    var viewStore: ComposableArchitecture.ViewStore<BookFeature.State, BookFeature.Action>
    
    var body: some View {
        Button(action: { 
            viewStore.send(.changePlaybackSpeed)
        }) {
            Text("Speed x\(viewStore.playbackSpeed.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", viewStore.playbackSpeed) : String(format: "%.2f", viewStore.playbackSpeed))")
                .font(.system(size: 13, weight: .medium, design: .default))
        }
        .frame(width: 78, height: 10)
        .padding(12)
        .background(Color.gray.opacity(0.15))
        .foregroundColor(.black)
        .cornerRadius(6)
    }
}

#Preview {
    WithViewStore( Store(
        initialState: BookFeature.State()
    ) {
        BookFeature()
    }, observe: { $0 }) { viewStore in
        SpeedChangerView(viewStore: viewStore)
    }
}
