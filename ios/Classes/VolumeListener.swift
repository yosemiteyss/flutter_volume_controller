//
//  VolumeListener.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import AVFoundation
import Foundation

class VolumeListener: NSObject, FlutterStreamHandler {
    private let audioSession: AVAudioSession
    private let volumeController: VolumeController
    
    private var outputVolumeObservation: NSKeyValueObservation?
    
    var isListening: Bool {
        return outputVolumeObservation != nil
    }
    
    init(audioSession: AVAudioSession, volumeController: VolumeController) {
        self.audioSession = audioSession
        self.volumeController = volumeController
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        do {
            let args = arguments as! [String: Any]
            let category = AudioSessionCategory.allCases[args[MethodArg.audioSessionCategory] as! Int]
            let emitOnStart = args[MethodArg.emitOnStart] as! Bool
            
            try volumeController.setAudioSessionCategory(category)

            outputVolumeObservation = audioSession.observe(\.outputVolume) { session, _ in
                events(String(session.outputVolume))
            }
            
            if emitOnStart {
                events(String(audioSession.outputVolume))
            }
        } catch {
            return FlutterError(
                code: ErrorCode.registerVolumeListener,
                message: ErrorMessage.registerVolumeListener,
                details: error.localizedDescription
            )
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        outputVolumeObservation = nil
        try? volumeController.deactivateAudioSession()
        return nil
    }
}
