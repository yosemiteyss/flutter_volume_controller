//
//  OutputDevice.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 15/5/2023.
//

import Foundation
import CoreAudio

struct OutputDevice: Codable {
    let id: AudioDeviceID
    let name: String?
    let volumeControl: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, name, volumeControl
    }
    
    init(id: AudioDeviceID, name: String?, volumeSupported: Bool) {
        self.id = id
        self.name = name
        self.volumeControl = volumeSupported
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = AudioDeviceID(try container.decode(String.self, forKey: .id))!
        self.name = try container.decode(String?.self, forKey: .name)
        self.volumeControl = try container.decode(Bool.self, forKey: .volumeControl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(id), forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(volumeControl, forKey: .volumeControl)
    }
    
    func toJSONString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}
