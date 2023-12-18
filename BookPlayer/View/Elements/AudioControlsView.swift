//
//  AudioControlsView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct AudioControlsView: View {
    
    @State private var chapterNumber = 0
    
    var totalChaptersCount = 3
    
    @State private var isPlaying = false 
    
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
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
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
    AudioControlsView()
}
