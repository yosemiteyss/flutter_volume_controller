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
    
    func raiseVolume(_ step: Float?) {
        Sound.output.increaseVolume(by: step ?? 0.15)
    }
    
    func lowerVolume(_ step: Float?) {
        Sound.output.decreaseVolume(by: step ?? 0.15)
    }
}
