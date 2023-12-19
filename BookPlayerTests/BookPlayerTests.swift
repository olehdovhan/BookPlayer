//
//  BookPlayerTests.swift
//  BookPlayerTests
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import ComposableArchitecture
import XCTest
@testable import BookPlayer

@MainActor
final class BookPlayerTests: XCTestCase {
    
    let clock = TestClock()
    
    func testPlayHappyPath() async {
        let currentTime = ActorIsolated(0.0)
        let store = TestStore(
            initialState: BookFeature.State(duration: 1.25)
        ) {
            BookFeature()
        } withDependencies: {
            $0.audioPlayer.preparePlayer = { _,_ in
                try await self.clock.sleep(for: .milliseconds(1_250))
                return true
            }
            $0.continuousClock = self.clock
          
            $0.audioPlayer.currentTime = {
                await  currentTime.withValue { $0 += 0.5 }
                return await currentTime.value }
        }
        
        await store.send(.playButtonTapped) {
            $0.mode = .playing(progress: 0)
        }
        await self.clock.advance(by: .milliseconds(500))
        await store.receive(\.timerUpdated) {
            $0.mode = .playing(progress: 0.4)
            $0.bookCurrentTime = 0.5
        }
        await self.clock.advance(by: .milliseconds(500))
        await store.receive(\.timerUpdated) {
            $0.mode = .playing(progress: 0.8)
            $0.bookCurrentTime = 1.0
        }

        await self.clock.advance(by: .milliseconds(250))
        await store.receive(\.audioPlayerClient.success) {
            $0.bookCurrentTime = 0.0
            $0.mode = .notPlaying
            $0.alert = AlertState { TextState("Congratulations! \n You have finished listening current book.") }
        }
    }
    
    func testPlayFailure() async {
        struct SomeError: Error, Equatable {}
        
        let store = TestStore(
            initialState: BookFeature.State()
        ) {
            BookFeature()
        } withDependencies: {
            $0.audioPlayer.preparePlayer = { _,_ in throw SomeError() }
            $0.continuousClock = self.clock
        }
        
        let task = await store.send(.playButtonTapped) {
            $0.mode = .playing(progress: 0)
        }
        await store.receive(\.audioPlayerClient.failure) {
            $0.mode = .notPlaying
            $0.alert = AlertState { TextState("Audiobook playback failed.") }
        }
        await task.cancel()
    }
}
