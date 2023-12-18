//
//  SwiftUIView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct SliderView: View {
    
    let dateComponentsFormatter: DateComponentsFormatter = {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.minute, .second]
      formatter.zeroFormattingBehavior = .pad
      return formatter
    }()
    
    @State var progress: Double = 0.5
    
    var body: some View {
        HStack(spacing: 5) {
            
            dateComponentsFormatter.string(from: 12.0).map {
                Text($0)
                    .font(.footnote.monospacedDigit())
            }
            
            Slider(
                value: $progress,
                in: 0.0...1.0,
                onEditingChanged: { isEditing in  }
            )
            .onAppear {
                UISlider.appearance().setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
            }
            dateComponentsFormatter.string(from: 30).map {
                Text($0)
                    .font(.footnote.monospacedDigit())
            }
        }
        .foregroundColor(.gray)
        .padding(.horizontal,28)
    }
}

#Preview {
    SliderView()
}
