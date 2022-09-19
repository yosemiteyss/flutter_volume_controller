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
}

struct MethodArg {
    static let volume = "volume"
    static let step = "step"
    static let showSystemUI = "showSystemUI"
}

struct ErrorCode {
    static let `default` = "1000"
}

struct ErrorMessage {
    static let getVolume = "Failed to get volume"
    static let setVolume = "Failed to set volume"
    static let raiseVolume = "Failed to raise volume"
    static let lowerVolume = "Failed to lower volume"
    static let registerListener = "Failed to register volume listener"
}
