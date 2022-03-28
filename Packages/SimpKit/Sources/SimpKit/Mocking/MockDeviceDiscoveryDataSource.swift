//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-28.
//

import Foundation

public struct MockDeviceDiscoveryDataSource: DeviceDiscoveryDataSource {
    
    public init() {}
    
    public func allDevices() async throws -> [Device] {
        Device.mock()
    }
}
