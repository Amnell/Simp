//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-24.
//

import Foundation
import Combine

@MainActor
public class DeviceDiscoveryManager: ObservableObject {
    @Published public var devices: [Device] = []

    private let appDiscoveryService: ApplicationDiscoveryService
    private var timerCancellable: AnyCancellable?
    private let queue = DispatchQueue(label: "DeviceDiscoveryManager.queue", qos: .utility)

    public init(appDiscoveryService: ApplicationDiscoveryService = ApplicationDiscoveryService()) {
        self.appDiscoveryService = appDiscoveryService
    }

    public func startFetch(interval: TimeInterval = 5) {
        let timerPublisher = Timer.publish(every: interval, tolerance: nil, on: .main, in: .default).autoconnect()
        let initialDate = Just(Date()) // Just to fire off the fetch imediately

        timerCancellable = Publishers.Merge(timerPublisher, initialDate)
            .receive(on: queue)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task.init {
                    do {
                        try await self.asyncFetch()
                    } catch {
                        assertionFailure("error: \(error)")
                    }
                }
            }
    }

    public func stopFetch() {
        timerCancellable?.cancel()
    }

    @discardableResult
    public func asyncFetch() async throws -> [Device] {
        let output = Process.cmd("/usr/bin/xcrun simctl list --json")

        let data = output.data(using: .utf8)!
        let listResult = try JSONDecoder().decode(DevicesResult.self, from: data)


        let devices = await withThrowingTaskGroup(of: [Device].self) { group -> [Device] in
            var theDevices: [Device] = []
            
            for var device in listResult.devices {
                if device.state == .booted {
                    device.applications = try? await appDiscoveryService.apps(in: device)
                }
                theDevices.append(device)
            }
            return theDevices
        }

        self.devices = devices
        
        return devices
    }
}
