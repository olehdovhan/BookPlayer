//
//  DummyToggleView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct DummyToggleView: View {
    
    @State private var position: CGFloat = 0.0
    @State private var isAudioSelected = true
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 60)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 60)
                            .fill(Color.white)
                    )
                
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.linear(duration: 0.25)) {
                            isAudioSelected = true
                            position = 0
                        }
                    }) {
                        ZStack {
                            Color.blue.clipShape(Circle())
                                .frame(width: 54)
                                .offset(x: position)
                            Image(systemName: "headphones")
                                .foregroundColor(isAudioSelected ? .white : .black)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.linear(duration: 0.25)) {
                            isAudioSelected = false
                            position = 58
                        }
                    }) {
                        ZStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(isAudioSelected ? .black : .white)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }.padding(.leading, -14)
            }
            .frame(width: 118, height: 60)
        }
    }
}

#Preview {
    DummyToggleView()
}
