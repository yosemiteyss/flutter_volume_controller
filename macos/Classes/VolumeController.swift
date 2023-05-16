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
        return try SoundOutputManager.shared.readVolume()
    }
    
    func setVolume(_ volume: Float) throws {
        try SoundOutputManager.shared.setVolume(volume)
    }
    
    func raiseVolume(_ step: Float?) throws {
        try SoundOutputManager.shared.increaseVolume(by: step ?? 0.15)
    }
    
    func lowerVolume(_ step: Float?) throws {
        try SoundOutputManager.shared.decreaseVolume(by: step ?? 0.15)
    }
    
    func getMute() throws -> Bool {
        return try SoundOutputManager.shared.readMute();
    }
    
    func setMute(_ isMuted: Bool) throws {
        try SoundOutputManager.shared.mute(isMuted)
    }
    
    func toggleMute() throws {
        let isMuted = try getMute()
        try setMute(!isMuted)
    }
    
    func getDefaultOutputDevice() throws -> OutputDevice {
        return try SoundOutputManager.shared.retrieveDefaultOutputDevice()
    }
    
    func setDefaultOutputDevice(_ deviceId: String) throws {
        try SoundOutputManager.shared.setDefaultOutputDevice(deviceId)
    }
    
    func getOutputDeviceList() throws -> [OutputDevice] {
        return try SoundOutputManager.shared.retrieveOutputDeviceList()
    }
}
