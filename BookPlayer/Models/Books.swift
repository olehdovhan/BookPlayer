//
//  Books.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import ComposableArchitecture
import SwiftUI

enum Books: String, CaseIterable{
    case seagull = "JonathanLivingstonSeagull"
    case cleanCode = "CleanCode"
    case illusions = "Illusions"
}

extension Books: Identifiable {
    var id: String { return self.rawValue }
}

extension Books {
    var url: URL {
        Bundle.main.url(forResource: self.rawValue, withExtension: "m4b")!
    }
    
    var name: String {
        switch self {
        case .seagull: return "Richard Bach - Jonathan Livingston Seagull"
        case .cleanCode: return "Uncle Bob - Clean Code"
        case .illusions: return "Illusions: The Adventures of a Reluctant Messiah"
        }
    }
}
