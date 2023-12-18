//
//  SwiftUIView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct ChapterInfoView: View {
    
        var body: some View {
            VStack {
                Text("Key point 1 of 7")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)

                Text("Chapter title")
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
    ChapterInfoView()
}
