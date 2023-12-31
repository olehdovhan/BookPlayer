//
//  PreviewView.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct Book {
    var image: UIImage
    var chapters: [Chapter]
}

struct PreviewView: View {
    
    static var store = Store(initialState: BookFeature.State(chapters: [])) { BookFeature() }
    
    //@State private var store = Store(initialState: BookFeature.State(chapters: [])) { BookFeature() }
    
    @State private var isMainViewShowed = false

    @State private var alertIsShowed = false
    
    var body: some View {
            ZStack {
                VStack {
                    Spacer()
                    Text("Choose book:")
                        .font(.largeTitle)
                        .padding(25)

                    ForEach(Books.allCases, id: \.id ) { book in
                        Button {
                            Task { await getMetadata(book.url) }
                        } label: {
                            Text(book.name)
                                .font(.headline)
                                
                        }
                        .padding(10)
                    }
                    Spacer()
                }
            }
            .alert("Metadata load error", isPresented: $alertIsShowed) {
                Button("OK", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $isMainViewShowed) {
                BookPlayerView(store: PreviewView.store)
            }
    }
    
    private func getMetadata(_ url: URL) async {
        
        let book = await MediaService.shared.getMetadata(from: url)

        guard let book = book else {
         alertIsShowed = true
            return }
        
        PreviewView.store = Store(initialState: BookFeature.State(url: url,
                                                           coverImage: Image(uiImage: book.image),
                                                          chapters: book.chapters )) { BookFeature()._printChanges()}
         isMainViewShowed = true
    }
}

#Preview {
    PreviewView()
}
