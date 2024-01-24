//
//  VideoPlayerView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import AVKit

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var avAsset: AVAsset?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
