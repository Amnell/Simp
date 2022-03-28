//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-24.
//

import Foundation
import Combine
import SwiftUI

public protocol DeviceDiscoveryDataSource {
    func allDevices() async throws -> [Device]
}

public struct FilesystemDeviceDiscoveryDataSource: DeviceDiscoveryDataSource {
    let appDiscoveryService: ApplicationDiscoveryServiceType
    
    public init() {
        self.appDiscoveryService = ApplicationDiscoveryService()
    }
    
    public func allDevices() async throws -> [Device] {
        let output = try await Process.cmd("/usr/bin/xcrun simctl list --json")
        
        let data = output.data(using: .utf8)!
        let listResult = try JSONDecoder().decode(DevicesResult.self, from: data)
        
        var devices: [Device] = []
        
        for var device in listResult.devices {
            device.applications = try? await appDiscoveryService.apps(in: device)
            devices.append(device)
        }
        
        devices = devices.sorted(by: { lhs, rhs in
            if lhs.name == rhs.name {
                return lhs.udid < rhs.udid
            }
            
            return (lhs.name < rhs.name)
        })
        
        return devices
    }
}

public class DeviceDiscoveryManager: ObservableObject {
    @Published public var devices: [Device] = []

    private var timerCancellable: AnyCancellable?
    private let queue = DispatchQueue(label: "DeviceDiscoveryManager.queue", qos: .utility)
    private let dataSource: DeviceDiscoveryDataSource
    
    public init(dataSource: DeviceDiscoveryDataSource) {
        self.dataSource = dataSource
    }

    public func startFetch(interval: TimeInterval = 5) {
        let timerPublisher = Timer.publish(every: interval, tolerance: nil, on: .main, in: .default).autoconnect()
        let initialDate = Just(Date()) // Just to fire off the fetch imediately

        timerCancellable = Publishers.Merge(timerPublisher, initialDate)
            .receive(on: queue)
            .asyncMap { _ in
                try await self.asyncFetch()
            }
            .catch({ _ in Just([]) })
            .receive(on: RunLoop.main)
            .assign(to: \.devices, on: self)
    }

    public func stopFetch() {
        timerCancellable?.cancel()
    }

    @discardableResult
    public func asyncFetch() async throws -> [Device] {
        try await dataSource.allDevices()
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>,
                            Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
