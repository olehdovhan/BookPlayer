//
//  BookFeature.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BookFeature {
    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var date = Date.now
        var duration: TimeInterval = 10.0
        var mode = Mode.notPlaying
        var bookCurrentTime: Double = 0.0

        var url =  Bundle.main.url(forResource: "CleanCode", withExtension: "m4b")!
        
        @CasePathable
        @dynamicMemberLookup
        enum Mode: Equatable {
            case notPlaying
            case playing(progress: Double)
            case pause
        }
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case audioPlayerClient(Result<Bool, Error>)
        case playButtonTapped
        case timerUpdated(TimeInterval)

        enum Alert: Equatable {}
    }
    
    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.continuousClock) var clock
    
    private enum CancelID { case play }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert:
                return .none
                
            case .audioPlayerClient(.failure):
                state.mode = .notPlaying
                state.alert = AlertState { TextState("Audiobook playback failed.") }
                return  .cancel(id: CancelID.play)

            case .audioPlayerClient:
                state.bookCurrentTime = 0.0
                state.alert = AlertState { TextState("Congratulations! \n You have finished listening current book.") }
                state.mode = .notPlaying
                return .cancel(id: CancelID.play)
                
            case .playButtonTapped:
                switch state.mode {
                case .notPlaying:
                    state.mode = .playing(progress: 0)
                    
                    return .run { [url = state.url, startTime = state.bookCurrentTime] send in
                        
                        async let playAudio: Void = send(
                            .audioPlayerClient(Result { try await self.audioPlayer.preparePlayer(url, startTime)})
                        )
                        
                        for await _ in self.clock.timer(interval: .milliseconds(500)) {
                            await send(.timerUpdated(audioPlayer.currentTime()))
                        }
                        
                        await playAudio
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true)
                    
                case .playing:
                    state.mode = .pause
                    return .run { send in
                        await self.audioPlayer.pause()
                    }
                case .pause:
                   state.mode = .playing(progress: state.bookCurrentTime / state.duration)
                    return .run { send in
                    await self.audioPlayer.play()
                    }
                }
                
            case let .timerUpdated(totalTime):
                switch state.mode {
                case .notPlaying:
                    break
                case .playing:
                    state.bookCurrentTime = totalTime
                    state.mode = .playing(progress: state.bookCurrentTime / state.duration)
                case .pause:
                    break
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
