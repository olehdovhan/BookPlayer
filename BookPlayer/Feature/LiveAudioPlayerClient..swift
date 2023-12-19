//
//  LiveAudioPlayerClient..swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import AVFoundation
import Dependencies

extension AudioPlayerClient: DependencyKey {
    static var liveValue: Self {
        let audioPlayer = AudioPlayer()
        
        return Self(preparePlayer: { url, time in try await audioPlayer.preparePlayer(url: url, startTime: time) },
                    play: { await audioPlayer.play()},
                    pause: { await audioPlayer.pause()},
                    currentTime: {await audioPlayer.currentTime()})
    }
}

private actor AudioPlayer {
    var delegate: Delegate?
    var player: AVAudioPlayer?
    var speed: Float?
    
    func pause() {
        self.player?.pause()
    }
    
    func play() {
        self.player?.play()
    }
    
    func currentTime() -> Double {
        return self.player?.currentTime ?? 0.0
    }

    func preparePlayer(url: URL, startTime: Double) async throws -> Bool {
        let stream = AsyncThrowingStream<Bool, Error> { continuation in
            do {
                
                self.delegate = Delegate(
                    didFinishPlaying: { successful in
                        continuation.yield(successful)
                        continuation.finish()
                    },
                    decodeErrorDidOccur: { error in
                        continuation.finish(throwing: error)
                    }
                )
                let player = try AVAudioPlayer(contentsOf: url)
                player.enableRate = true
                player.prepareToPlay()
                player.rate = speed ?? 1.0
                player.currentTime = startTime
                player.play()
                self.player = nil
                
                self.player = player
                player.delegate = self.delegate
                
                continuation.onTermination = { [player = UncheckedSendable(player)] _ in
                    player.wrappedValue.stop()
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
        return try await stream.first(where: { _ in true }) ?? false
    }
}

private final class Delegate: NSObject, AVAudioPlayerDelegate, Sendable {
    let didFinishPlaying: @Sendable (Bool) -> Void
    let decodeErrorDidOccur: @Sendable (Error?) -> Void
    
    init(
        didFinishPlaying: @escaping @Sendable (Bool) -> Void,
        decodeErrorDidOccur: @escaping @Sendable (Error?) -> Void
    ) {
        self.didFinishPlaying = didFinishPlaying
        self.decodeErrorDidOccur = decodeErrorDidOccur
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlaying(flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.decodeErrorDidOccur(error)
    }
}


