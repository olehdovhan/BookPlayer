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
        var playbackSpeed: Float = 1.0
        var url =  Bundle.main.url(forResource: "CleanCode", withExtension: "m4b")!
        
        var coverImage = Image(systemName: "book")

        var chapters: [Chapter]
        var currentChapterIndex = 0
        var currentChapter: Chapter {
            return chapters[currentChapterIndex]
        }
        var chapterCurrentTime: Double {
            return bookCurrentTime - currentChapter.start
        }
        
        var currentChapterTitle: String {
            guard (chapters.count - 1) >= currentChapterIndex  else { return "" }
            return currentChapter.title
        }
        
        var progress: Double = 0.0
        var sliderIsDragging = false
        
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
        case changePlaybackSpeed
        case defaultPlaybackSpeed
        case nextChapter
        case previousChapter
        case progressChanged(Double)
        case updateSliderStatus(Bool)
        case backward(seconds: Double)
        case forward(seconds: Double)
        case stopPlayer


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
                state.currentChapterIndex = 0
                state.progress = 0.0
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
                    let newProgress = state.chapterCurrentTime / state.currentChapter.duration
                    if !state.sliderIsDragging {
                        state.progress = newProgress
                        }
                    state.mode = .playing(progress: newProgress)

                 if state.chapters.count > state.currentChapterIndex + 1 {
                       let start = state.chapters[state.currentChapterIndex + 1].start
                        if  totalTime > start {
                               state.currentChapterIndex += 1
                           }
                    }
                case .pause:
                    break
                }
                return .none
            case .changePlaybackSpeed:
                let newSpeed = state.playbackSpeed + 0.25
                state.playbackSpeed  = newSpeed > 2 ? 0.5 : newSpeed
                return .run
                { [speed = state.playbackSpeed] send in
                    await self.audioPlayer.changePlaybackSpeed(speed)
                }
                
            case .defaultPlaybackSpeed:
                state.playbackSpeed = 1.0
                return .run { [speed = state.playbackSpeed] send in
                        await self.audioPlayer.changePlaybackSpeed(speed)
                }

            case .nextChapter:
                if state.chapters.count > state.currentChapterIndex + 1 {
                    state.currentChapterIndex += 1
                    state.bookCurrentTime = state.currentChapter.start
                }
                return .run { [seekTime = state.currentChapter.start] _ in
                        await self.audioPlayer.seekTo(seekTime)
                }
            case .previousChapter:
                if state.currentChapterIndex > 0 {
                    state.currentChapterIndex -= 1
                    state.bookCurrentTime = state.currentChapter.start
                }
                return .run { [seekTime = state.currentChapter.start] _ in
                        await self.audioPlayer.seekTo(seekTime)
                }
            case .progressChanged(let newProgress):
                state.progress = newProgress
                let currentTime = MediaService.shared.progressToCMTime(value: newProgress,
                                                                      duration: Double(state.currentChapter.duration)).seconds
                let seekToTime = currentTime + state.currentChapter.start
                state.bookCurrentTime = seekToTime
                return .run { [seekToTime] send in
                    await self.audioPlayer.seekTo(seekToTime)
                }
            case let .updateSliderStatus(isDragging):
                state.sliderIsDragging = isDragging
                return .none
            case .backward(seconds: let seconds):
                let expectedTime = state.bookCurrentTime - seconds
                let seekToTime = expectedTime > state.currentChapter.start ? expectedTime : state.currentChapter.start
                state.bookCurrentTime = seekToTime
                let newProgress = state.chapterCurrentTime / state.currentChapter.duration
                if !state.sliderIsDragging {
                    state.progress = newProgress
                    }
                return .run {[seekToTime] _ in
                    await self.audioPlayer.seekTo(seekToTime)
                }
            case .forward(seconds: let seconds):
                let expectedTime = state.bookCurrentTime + seconds
                let seekToTime = expectedTime < state.currentChapter.end ? expectedTime : state.currentChapter.end
                state.bookCurrentTime = seekToTime
                let newProgress = state.chapterCurrentTime / state.currentChapter.duration
                if !state.sliderIsDragging {
                    state.progress = newProgress
                    }
                return .run { [seekToTime] _ in
                    await self.audioPlayer.seekTo(seekToTime)
                }
            case .stopPlayer:
                state.currentChapterIndex = 0
                state.progress = 0.0
                state.bookCurrentTime = 0.0
                state.playbackSpeed = 1.0
                state.mode = .notPlaying
                
                return .merge(.send(.defaultPlaybackSpeed),
                                    .cancel(id: CancelID.play))
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
