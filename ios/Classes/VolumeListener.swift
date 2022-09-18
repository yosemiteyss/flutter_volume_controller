//
//  VolumeListener.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import Foundation
import AVFoundation
import MediaPlayer

class VolumeListener: NSObject, FlutterStreamHandler {
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private let outputVolumeKeyPath: String = "outputVolume"
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        do {
            try audioSession.setActive(true)
            audioSession.addObserver(
                self,
                forKeyPath: outputVolumeKeyPath,
                options: [.new],
                context: nil
            )
        } catch {
            return FlutterError(
                code: ErrorCode.default,
                message: ErrorMessage.registerListener,
                details: error.localizedDescription
            )
        }
        
        return nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == outputVolumeKeyPath {
            guard let volume = change?[.newKey] as? Float else { return }
            self.eventSink?(volume)
        }
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        audioSession.removeObserver(self, forKeyPath: outputVolumeKeyPath)
        return nil
    }
}
