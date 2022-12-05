//
//  VolumeController.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 17/9/2022.
//

import Foundation
import FlutterMacOS

class VolumeController {
    func getVolume() throws -> Double {
        return Double(try Sound.output.readVolume())
    }
    
    func setVolume(_ volume: Double) throws {
        try Sound.output.setVolume(Float(volume))
    }
    
    func raiseVolume(_ step: Double?) throws {
        try Sound.output.increaseVolume(by: Float(step ?? 0.15))
    }
    
    func lowerVolume(_ step: Double?) throws {
        try Sound.output.decreaseVolume(by: Float(step ?? 0.15))
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
