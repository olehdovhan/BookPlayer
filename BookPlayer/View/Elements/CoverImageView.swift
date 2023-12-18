//
//  CoverImageView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 18.12.2023.
//

import SwiftUI

struct CoverImageView: View {
    var coverImage: Image
    
    var body: some View {
        coverImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(30)
    }
}

#Preview {
    CoverImageView(coverImage: Image(systemName: "book"))
}

