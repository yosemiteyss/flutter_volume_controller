//
//  VolumeController.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 17/9/2022.
//

import Foundation
import AVFoundation
import MediaPlayer

class VolumeController {
    private let volumeView: MPVolumeView = MPVolumeView()
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    func getVolume() throws -> Float? {
        return try audioSession.getVolume()
    }
    
    func setVolume(_ volume: Float, showSystemUI: Bool) {
        setShowSystemUI(showSystemUI);
        volumeView.setVolume(volume)
    }
    
    func raiseVolume(_ step: Float?, showSystemUI: Bool) {
        setShowSystemUI(showSystemUI);
        volumeView.raiseVolume(step ?? 0.15)
    }
    
    func lowerVolume(_ step: Float?, showSystemUI: Bool) {
        setShowSystemUI(showSystemUI);
        volumeView.lowerVolume(step ?? 0.15)
    }
    
    private func setShowSystemUI(_ show: Bool) {
        if show {
            volumeView.frame = CGRect()
            volumeView.showsRouteButton = true
            volumeView.removeFromSuperview()
        } else {
            volumeView.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
            volumeView.showsRouteButton = false
            UIApplication.shared.keyWindow?.insertSubview(volumeView, at: 0)
        }
    }
}

