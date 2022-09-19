//
//  VolumeListener.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import Foundation
import FlutterMacOS

class VolumeListener: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        do {
            try Sound.output.addVolumeChangeObserver { volume in
                events(volume)
            }
        } catch {
            return FlutterError(
                code: ErrorCode.default,
                message: ErrorMessage.registerListener,
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
            return FlutterError(
                code: ErrorCode.default,
                message: ErrorMessage.registerListener,
                details: error.localizedDescription
            )
        }
        
        return nil
    }
}
