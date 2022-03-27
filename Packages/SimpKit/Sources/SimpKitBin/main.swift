//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-24.
//

import Foundation
import SimpKit

@main struct Main {
    static func main() async {
        do {
            let devices = try await DeviceDiscoveryManager(appDiscoveryService: ApplicationDiscoveryService()).asyncFetch()
            print(devices.filter({ $0.state == .booted }))
        } catch {
            print(error)
        }
    }
}
