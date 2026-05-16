//
//  VolumeController.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 17/9/2022.
//

import Foundation
import FlutterMacOS

class VolumeController {
    func getVolume() throws -> Float {
        return try Sound.output.readVolume()
    }
    
    func setVolume(_ volume: Float) throws {
        try Sound.output.setVolume(volume)
    }
    
    func raiseVolume(_ step: Float?) throws {
        try Sound.output.increaseVolume(by: step ?? 0.15)
    }
    
    func lowerVolume(_ step: Float?) throws {
        try Sound.output.decreaseVolume(by: step ?? 0.15)
    }
    
    func getMute() throws -> Bool {
        return try Sound.output.readMute();
    }
    
    func setMute(_ isMuted: Bool) throws {
        try Sound.output.mute(isMuted)
    }
    
    func toggleMute() throws {
        let isMuted = try getMute()
        try setMute(!isMuted)
    }
}
