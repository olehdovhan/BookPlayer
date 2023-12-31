//
//  AudioPlayerClient.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

struct AudioPlayerClient {
  var preparePlayer: @Sendable (URL, Double) async throws -> Bool
  var play: @Sendable () async -> Void
  var pause: @Sendable () async -> Void
  var currentTime: @Sendable () async -> TimeInterval
  var changePlaybackSpeed: @Sendable (Float) async -> Void
  var seekTo: @Sendable (Double) async -> Void
}

extension AudioPlayerClient: TestDependencyKey {
    static var previewValue: Self {
     let isPlaying = ActorIsolated(false)
     let currentTime = ActorIsolated(0.0)

        return Self(
    preparePlayer: { _, _ in
        try await Task.sleep(for: .seconds(5))
        return true
    },
    play: { await isPlaying.setValue(false) },
    pause: { await isPlaying.setValue(true) },
    currentTime: { await currentTime.value},
    changePlaybackSpeed: { float in }, 
    seekTo:  { seekTo in }  )
    }
    

  static let testValue = Self(
    preparePlayer: unimplemented("\(Self.self).playerPrepared", placeholder: true),
    play: unimplemented("\(Self.self).play"),
    pause: unimplemented("\(Self.self).pause"),
    currentTime: unimplemented("\(Self.self).currentTime"),
    changePlaybackSpeed: unimplemented("\(Self.self).changePlaybackSpeed"),
    seekTo: unimplemented("\(Self.self).seekTo"))
  }

extension DependencyValues {
  var audioPlayer: AudioPlayerClient {
    get { self[AudioPlayerClient.self] }
    set { self[AudioPlayerClient.self] = newValue }
  }
}
