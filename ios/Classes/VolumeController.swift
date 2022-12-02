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
    
    private var savedVolume: Float?
    
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
    
    func getMute() throws -> Bool {
        return try getVolume() == 0;
    }
    
    func setMute(_ isMuted: Bool, showSystemUI: Bool) throws {
        // Save current volume level before mute.
        if isMuted {
            savedVolume = try getVolume()
            setVolume(0, showSystemUI: showSystemUI)
            return;
        }
        
        // Restore to the volume level before mute.
        let volume = savedVolume ?? 0.5
        setVolume(volume, showSystemUI: showSystemUI)
        
        savedVolume = nil
    }
    
    func toggleMute(showSystemUI: Bool) throws {
        let isMuted = try getMute()
        try setMute(!isMuted, showSystemUI: showSystemUI)
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

