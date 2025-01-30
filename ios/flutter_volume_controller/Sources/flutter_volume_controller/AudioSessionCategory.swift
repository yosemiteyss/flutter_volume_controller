//
//  AudioSessionCategory.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 30/1/2023.
//

import AVFoundation

enum AudioSessionCategory: CaseIterable {
    case ambient
    case multiRoute
    case playAndRecord
    case playback
    case record
    case soloAmbient
    
    var categoryType: AVAudioSession.Category {
        switch self {
        case .ambient:
            return AVAudioSession.Category.ambient
        case .multiRoute:
            return AVAudioSession.Category.multiRoute
        case .playAndRecord:
            return AVAudioSession.Category.playAndRecord
        case .playback:
            return AVAudioSession.Category.playback
        case .record:
            return AVAudioSession.Category.record
        case .soloAmbient:
            return AVAudioSession.Category.soloAmbient
        }
    }
}
