//
//  DismissButton.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import SwiftUI

struct DismissButton: View {
    
    let closure: () -> ()
    var body: some View {
        HStack {
            Button {
               closure()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.black)
            }
            .frame(width: 25)
            .padding(.leading, 25)
            Spacer()
        }
    }
}

