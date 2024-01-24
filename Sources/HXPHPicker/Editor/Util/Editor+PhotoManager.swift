//
//  Editor+PhotoManager.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/28.
//

import AVKit

extension PhotoManager: AVAudioPlayerDelegate {
    
    @discardableResult
    public func playMusic(filePath path: String, finished: @escaping () -> Void) -> Bool {
        audioPlayFinish = finished
        
        let url = URL(fileURLWithPath: path)
        
        //        if let currentURL = audioPlayer?.url,
        //           currentURL.absoluteString == url.absoluteString {
        //
        //            restart()
        //            return true
        //        }
        
        if audioSession.category != .playback {
            do {
                try audioSession.setCategory(.playback)
                try audioSession.setActive(true)
            } catch {
                // print(error)
            }
        }
        
        //        do {
        audioPlayer = AVPlayer(url: url) // try AVAudioPlayer(contentsOf: url)
        //        } catch {
        //            let fileTypes: [AVFileType] = [.m4a, .mp3, .mov, .m4v, .mp4]
        //            for fileType in fileTypes {
        //                do {
        //                    audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: fileType.rawValue)
        //                    break
        //                } catch {
        //                    // print(error)
        //                }
        //            }
        //        }
        
        if let audioPlayer = audioPlayer {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: audioPlayer.currentItem, queue: .main) { notification in
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if self.audioPlayer?.currentItem === (notification.object as? AVPlayerItem) {
                        self.restart()
                        self.audioPlayFinish?()
                    }
                }
            }
        } else {
            audioPlayFinish = nil
            return false
        }
        
        // audioPlayer?.delegate = self
        restart()
        
        return true
    }
    
    public func stopPlayMusic() {
        audioPlayer?.pause() // audioPlayer?.stop()
        // audioPlayer?.delegate = nil
        audioPlayer = nil
        audioPlayFinish = nil
    }
    
    public func changeAudioPlayerVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    //    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    //        if flag {
    //            restart()
    //            audioPlayFinish?()
    //        }
    //    }
    
    public func restart() {
        // audioPlayer?.prepareToPlay()
        // audioPlayer?.currentTime = 0
        audioPlayer?.seek(to: .zero)
        audioPlayer?.play()
    }
}
