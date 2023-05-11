//
//  SoundOutputManager+Errors.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 11/5/2023.
//

import Foundation

extension SoundOutputManager {
    enum Errors: Error {
        /// The system couldn't complete the requested operation and
        /// returned the given status.
        case  operationFailed(OSStatus)
        /// The current default output device doesn't support the requested property.
        case  unsupportedProperty
        /// The current default output device doesn't allow changing the requested property.
        case  immutableProperty
        /// There is no default output device.
        case  noDevice
    }
}
