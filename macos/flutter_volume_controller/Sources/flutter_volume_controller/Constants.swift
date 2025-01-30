//
//  Constants.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 18/9/2022.
//

import Foundation

struct MethodName {
    static let getVolume = "getVolume"
    static let setVolume = "setVolume"
    static let raiseVolume = "raiseVolume"
    static let lowerVolume = "lowerVolume"
    static let getMute = "getMute"
    static let setMute = "setMute"
    static let toggleMute = "toggleMute"
}

struct MethodArg {
    static let volume = "volume"
    static let step = "step"
    static let showSystemUI = "showSystemUI"
    static let emitOnStart = "emitOnStart"
    static let isMuted = "isMuted"
}

struct ErrorCode {
    static let getVolume = "1000"
    static let setVolume = "1001"
    static let raiseVolume = "1002"
    static let lowerVolume = "1003"
    static let registerVolumeListener = "1004"
    static let getMute = "1005"
    static let setMute = "1006"
    static let toggleMute = "1007"
}

struct ErrorMessage {
    static let getVolume = "Failed to get volume"
    static let setVolume = "Failed to set volume"
    static let raiseVolume = "Failed to raise volume"
    static let lowerVolume = "Failed to lower volume"
    static let registerVolumeListener = "Failed to register volume listener"
    static let getMute = "Failed to get mute"
    static let setMute = "Failed to set mute"
    static let toggleMute = "Failed to toggle mute"
}
