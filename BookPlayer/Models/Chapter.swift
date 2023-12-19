//
//  Chapter.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import Foundation

struct Chapter: Equatable {
    let chapterIndex: Int
    let title: String
    let start: Double
    let end: Double
    let duration: Double
    
    init(title: String, chapterNumber: Int ,start: Double,end: Double, duration: Double) {
        self.chapterIndex = chapterNumber
        self.title = title
        self.start = start
        self.end = end
        self.duration = duration
    }
    
    static let mock = [Chapter(title: "first Chapter",
                               chapterNumber: 1,
                               start: 0.0 ,
                               end: 1.25,
                               duration: 1.25),
                       
                       Chapter(title: "second Chapter",
                               chapterNumber: 2,
                               start: 1.25,
                               end: 2.25 ,
                               duration: 1.25)]
}
