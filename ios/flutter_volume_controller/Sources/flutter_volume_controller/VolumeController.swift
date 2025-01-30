//
//  VolumeController.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 17/9/2022.
//

import AVFoundation
import Foundation
import MediaPlayer

class VolumeController {
    private static let defaultStep: Double = 0.15
    
    private let audioSession: AVAudioSession
    private let volumeView: MPVolumeView = .init()
    
    private var volumeBeforeMute: Float?
    
    init(audioSession: AVAudioSession) {
        self.audioSession = audioSession
    }
    
    func getVolume() throws -> Float {
        try audioSession.setActive(true)
        let volume = audioSession.outputVolume
        return volume
    }
    
    func setVolume(_ volume: Double, showSystemUI: Bool) throws {
        setShowSystemUI(showSystemUI)
        volumeView.setVolume(volume)
    }
    
    func raiseVolume(_ step: Double?, showSystemUI: Bool) throws {
        setShowSystemUI(showSystemUI)
        volumeView.raiseVolume(step ?? VolumeController.defaultStep)
    }
    
    func lowerVolume(_ step: Double?, showSystemUI: Bool) throws {
        setShowSystemUI(showSystemUI)
        volumeView.lowerVolume(step ?? VolumeController.defaultStep)
    }
    
    func getMute() throws -> Bool {
        let volume = try getVolume()
        return volume == 0
    }
    
    func setMute(_ isMute: Bool, showSystemUI: Bool) throws {
        if isMute {
            // Save current volume level before mute.
            volumeBeforeMute = try getVolume()
            try setVolume(0, showSystemUI: showSystemUI)
        } else {
            // Restore previous volume level when unmute.
            if let volume = volumeBeforeMute {
                try setVolume(Double(volume), showSystemUI: showSystemUI)
                volumeBeforeMute = nil
            }
        }
    }
    
    func toggleMute(showSystemUI: Bool) throws {
        let isMuted = try getMute()
        try setMute(!isMuted, showSystemUI: showSystemUI)
    }
    
    func setAudioSessionCategory(_ category: AudioSessionCategory) throws {
        try audioSession.setCategory(category.categoryType)
        try audioSession.setActive(true)
    }
    
    func getAudioSessionCategory() throws -> AudioSessionCategory? {
        return AudioSessionCategory.allCases.first { category in category.categoryType == audioSession.category }
    }
    
    func activateAudioSession() throws {
        try audioSession.setActive(true)
    }
    
    func deactivateAudioSession() throws {
        try audioSession.setActive(false)
    }
    
    func setShowSystemUI(_ show: Bool) {
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
