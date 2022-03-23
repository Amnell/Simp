//
//  DeviceResult.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2021-12-06.
//

import Foundation

struct DevicesResult: Codable {
    public var devices: [Device] {
        _devices.values.flatMap { $0 }
    }

    private var _devices: [String: [Device]]

    enum CodingKeys: String, CodingKey {
        case _devices = "devices"
    }
}
