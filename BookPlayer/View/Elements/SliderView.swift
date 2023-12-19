//
//  SwiftUIView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//
import ComposableArchitecture
import SwiftUI

struct SliderView: ViewStoreViewProtocol {
    
    var viewStore: ComposableArchitecture.ViewStore<BookFeature.State, BookFeature.Action>
    
    let dateComponentsFormatter: DateComponentsFormatter = {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.minute, .second]
      formatter.zeroFormattingBehavior = .pad
      return formatter
    }()
    
    @State var progress: Double = 0.5
    
    var body: some View {
        HStack(spacing: 5) {
            
            dateComponentsFormatter.string(from: viewStore.chapterCurrentTime).map {
                Text($0)
                    .font(.footnote.monospacedDigit())
            }
            
            Slider(
                value: viewStore.binding(get: { $0.progress }, send: { .progressChanged($0) }),
                in: 0.0...1.0,
                onEditingChanged: { isEditing in
                    viewStore.send(.updateSliderStatus(isEditing))
                }
            )
            .onAppear {
                UISlider.appearance().setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
            }
            dateComponentsFormatter.string(from: viewStore.currentChapter.duration).map {
                Text($0)
                    .font(.footnote.monospacedDigit())
            }
        }
        .foregroundColor(.gray)
        .padding(.horizontal,28)
    }
}

//#Preview {
//    SliderView()
//}
