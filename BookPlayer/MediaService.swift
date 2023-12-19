//
//  MediaService.swift
//  BookPlayer
//
//  Created by Oleh Dovhan on 19.12.2023.
//

import AVFoundation
import UIKit

final class MediaService {
    
    static var shared: MediaService = { MediaService() }()
    
    private init() { }
    
    func setPlayingInSilentMode() {
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
           try AVAudioSession.sharedInstance().setActive(true)
           let sessionCategory = AVAudioSession.Category.playback.rawValue
           let _: AVAudioSession.Category = .ambient
           try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: sessionCategory))

       } catch {
           print("AVAudioSession error: \(error.localizedDescription)")
       }
    }
    
    func getMetadata(from url: URL) async -> Book? {
      
        let image = await loadArtworkImage(url)
        let chapters = await loadChapters(url)
        
        guard let image = image, let chapters = chapters else { return nil }
        
        return Book(image: image, chapters: chapters)
    }
    
    private func loadChapters(_ url: URL) async -> [Chapter]? {
        let asset = AVAsset(url: url)
        var chaptersData: [Chapter] = []
        do {
            let locales =  try await asset.load(.availableChapterLocales)
            for locale in locales {
                let chapters = try await asset.loadChapterMetadataGroups(withTitleLocale: locale ,
                                                                         containingItemsWithCommonKeys: [.commonKeyArtwork])
                
                for (index, chapterMetadata) in chapters.enumerated() {
                    let metadataItems = AVMetadataItem.metadataItems(from: chapterMetadata.items, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common)
                    let title = try await metadataItems.first?.load(.stringValue) ?? "Chapter"
                    let startTime = chapterMetadata.timeRange.start.seconds
                    let endTime = chapterMetadata.timeRange.end.seconds
                    let duration = CMTimeGetSeconds(chapterMetadata.timeRange.duration)
                    
                    let chapter = Chapter(title: title,
                                          chapterNumber: index + 1,
                                          start: startTime,
                                          end: endTime,
                                          duration: duration)
                    chaptersData.append(chapter)
                }
            }
            return chaptersData
        } catch let error as NSError {
            print("Error loading AVAsset: \(error)")
        }
        return nil
    }
    
   private func loadArtworkImage(_ url: URL) async -> UIImage? {
            do {
                let avAsset =  AVAsset(url: url)
                let metadata = try await avAsset.load(.metadata)
                
                let artworksMetadataItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtwork)
                
                if let item = artworksMetadataItems.last,
                   let image = await coverFrom(metadata: item) {
                    return image
                } else {
                    print("Artwork not found.")
                }
            } catch let error as NSError {
                print("AVAsse error loading: \(error)")
            }
        return nil
    }
    
    func progressToCMTime(value: Double, duration: Double) -> CMTime {
        let timeScale = CMTimeScale(100)
        let durationCMTime = CMTime(seconds: duration,
                                    preferredTimescale: timeScale)
        let ratio = 1 / value
        let total = CMTimeGetSeconds(durationCMTime)
        var currentSeconds = total / ratio
        print(currentSeconds)
        if currentSeconds.isNaN {
            currentSeconds = 0.0
        }
        return CMTime(seconds: currentSeconds, preferredTimescale: timeScale)
    }
    
    private func coverFrom(metadata: AVMetadataItem) async -> UIImage? {
        do {
            let dataValue = try await metadata.load(.dataValue)
            return UIImage(data: dataValue!)
        } catch let error as NSError {
            print("Error loading AVAsset: \(error)")
            return nil
        }
    }
    
}

extension MediaService: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
