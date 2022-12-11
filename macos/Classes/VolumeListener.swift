//
//  VolumeListener.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import Foundation
import FlutterMacOS

class VolumeListener: NSObject, FlutterStreamHandler {
    private let volumeController: VolumeController
    private var eventSink: FlutterEventSink?
    
    required init(volumeController: VolumeController) {
        self.volumeController = volumeController
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        do {
            let args = arguments as! [String: Any]
            let emitOnStart = args[MethodArg.emitOnStart] as! Bool
            
            try Sound.output.addVolumeChangeObserver { volume in
                events(String(volume))
            }
            
            if emitOnStart {
                let volume = try volumeController.getVolume()
                events(String(volume))
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
        eventSink = nil
        do {
            try Sound.output.removeVolumeChangeObserver()
        } catch {
            // No-op
        }
        
        return nil
    }
}
