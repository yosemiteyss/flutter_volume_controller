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
    private static let defaultCategory: AVAudioSession.Category = AVAudioSession.Category.ambient
    
    private let audioSession: AVAudioSession
    private let volumeView: MPVolumeView = .init()
    
    private var savedVolume: Float?
    private var currentCategory: AVAudioSession.Category = defaultCategory
    
    init(audioSession: AVAudioSession) {
        self.audioSession = audioSession
    }
    
    func getVolume() throws -> Float {
        try resumeAudioSession()
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
        try resumeAudioSession()
        return audioSession.outputVolume == 0
    }
    
    func setMute(_ isMuted: Bool, showSystemUI: Bool) throws {
        try resumeAudioSession()
        
        // Save current volume level before mute.
        if isMuted {
            savedVolume = audioSession.outputVolume
            try setVolume(0, showSystemUI: showSystemUI)
            return
        }
        
        // Restore to the volume level before mute.
        let volume = Double(savedVolume ?? 0.5)
        try setVolume(volume, showSystemUI: showSystemUI)
        savedVolume = nil
    }
    
    func toggleMute(showSystemUI: Bool) throws {
        let isMuted = try getMute()
        try setMute(!isMuted, showSystemUI: showSystemUI)
    }
    
    func setAudioSessionCategory(_ category: AudioSessionCategory) throws {
        try audioSession.activate(with: category.categoryType)
        currentCategory = category.categoryType
    }
    
    func getAudioSessionCategory() throws -> AudioSessionCategory? {
        return AudioSessionCategory.allCases.first { category in category.categoryType == audioSession.category }
    }
    
    func resumeAudioSession() throws {
        try audioSession.activate(with: currentCategory)
    }
    
    func deactivateAudioSession() throws {
        currentCategory = VolumeController.defaultCategory
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
