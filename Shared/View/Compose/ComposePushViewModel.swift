//
//  ComposePushViewModel.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2021-12-06.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ComposePushViewModel: ObservableObject {
    @ObservedObject var deviceDiscoveryService: DeviceDiscoveryService
    @ObservedObject var historyStore: HistoryStore<Push>

    @Published var devices: [Device] = []
    @Published var payload: String = ""
    @Published var bundleId: String = ""
    @Published var selectedDevice: Device?
    @Published var selectedApplication: AppData? {
        didSet {
            if let bundleIdentifier = selectedApplication?.bundleIdentifier {
                bundleId = bundleIdentifier
            }
        }
    }

    private var devicesCancellable: AnyCancellable?

    public var bootedDevices: [Device] {
        devices.filter({$0.state == .booted})
    }

    init(historyStore: HistoryStore<Push>, push: Push? = nil, deviceDiscoveryService: DeviceDiscoveryService) {
        self.historyStore = historyStore
        self.payload = push?.payload ?? ""
        self.bundleId = push?.bundleIdentifier ?? ""
        self.deviceDiscoveryService = deviceDiscoveryService
    }

    func load() {
        deviceDiscoveryService.startFetch(interval: 10)

        devicesCancellable = deviceDiscoveryService.$devices
            .assign(to: \.devices, on: self)
    }

    func send() throws {
        guard let selectedDevice = selectedDevice else {
            return
        }

        Task.init {
            let push = Push(payload: payload, bundleIdentifier: bundleId, date: Date())
            try await selectedDevice.asyncSend(push: push)
            historyStore.store(item: push)
        }
    }

}
