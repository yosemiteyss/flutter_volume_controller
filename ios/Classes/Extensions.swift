//
//  Extensions.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import Foundation
import MediaPlayer

extension MPVolumeView {
    func setVolume(_ volume: Double) {
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.async {
            slider?.value = Float(volume)
        }
    }
    
    func raiseVolume(_ step: Double) {
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.async {
            slider?.value += Float(step)
        }
    }
    
    func lowerVolume(_ step: Double) {
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.async {
            slider?.value -= Float(step)
        }
    }
}

extension AVAudioSession {
    func getVolume() throws -> Float {
        try setActive(true)
        return outputVolume
    }
}
