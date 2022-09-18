//
//  Extensions.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import Foundation
import MediaPlayer

extension MPVolumeView {
    func setVolume(_ volume: Float) {
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.async {
            slider?.value = volume
        }
    }
    
    func raiseVolume(_ step: Float) {
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.async {
            slider?.value += step
        }
    }
    
    func lowerVolume(_ step: Float) {
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.async {
            slider?.value -= step
        }
    }
}

extension AVAudioSession {
    func getVolume() throws -> Float? {
        try setActive(true)
        return outputVolume
    }
}
