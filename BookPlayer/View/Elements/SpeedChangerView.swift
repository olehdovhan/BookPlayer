//
//  SpeedChangerView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct SpeedChangerView: View {
    
    var playbackSpeed: Float = 1.0
    
    var body: some View {
        Button(action: { }) {
            Text("Speed x\(playbackSpeed.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", playbackSpeed) : String(format: "%.2f", playbackSpeed))")
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
    SpeedChangerView()
}
