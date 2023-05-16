//
//  OutputDevice.swift
//  flutter_volume_controller
//
//  Created by yosemiteyss on 15/5/2023.
//

import Foundation

struct OutputDevice: Codable {
    let id: String
    let name: String?

    func toJSONString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}
