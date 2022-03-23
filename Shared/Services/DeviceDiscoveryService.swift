//
//  DeviceDiscoveryService.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-02.
//

import Foundation
import Combine

actor DevicesActor {
    var value: [Device] = []
}

@MainActor
class DeviceDiscoveryService: ObservableObject {
    @Published var devices: [Device] = []

    private let appDiscoveryService: ApplicationDiscoveryService
    private var timerCancellable: AnyCancellable?
    private let queue = DispatchQueue(label: "DeviceDiscoveryService.queue", qos: .utility)

    init(appDiscoveryService: ApplicationDiscoveryService = DefaultApplicationDiscoveryService()) {
        self.appDiscoveryService = appDiscoveryService
    }

    func startFetch(interval: TimeInterval = 5) {
        let timerPublisher = Timer.publish(every: interval, tolerance: nil, on: .main, in: .default).autoconnect()
        let initialDate = Just(Date()) // Just to fire off the fetch imediately

        timerCancellable = Publishers.Merge(timerPublisher, initialDate)
            .receive(on: queue)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task.init {
                    try! await self.asyncFetch()
                }
            }
    }

    func stopFetch() {
        timerCancellable?.cancel()
    }

    private func asyncFetch() async throws {
        let output = try await Process.asyncExecute(path: URL(fileURLWithPath: "/usr/bin/xcrun"),
                                                    arguments: ["simctl", "list", "--json"],
                                                    input: nil)

        let data = output.data(using: .utf8)!
        let listResult = try JSONDecoder().decode(DevicesResult.self, from: data)


        let devices = try await withThrowingTaskGroup(of: [Device].self) { group -> [Device] in
            var theDevices: [Device] = []
            for var device in listResult.devices {
                device.applications = try await appDiscoveryService.apps(in: device)
                theDevices.append(device)
            }
            return theDevices
        }

        self.devices = devices
    }
}
