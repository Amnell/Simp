//
//  ComposePushViewModel.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2021-12-06.
//

import Foundation
import SwiftUI
import Combine
import SimpKit

@MainActor
class ComposePushViewModel: ObservableObject {
    @ObservedObject var deviceDiscoveryManager: DeviceDiscoveryManager
    @ObservedObject var historyStore: HistoryStore<Push>

    @Published var devices: [Device] = []
    @Published var payload: String = ""
    @Published var selectedDeviceId: String = ""
    @Published var selectedApplicationId: String = ""
    
    var selectedApplication: Application? {
        selectedDevice?.applications?.first(where: { $0.id == selectedApplicationId })
    }
    
    var selectedDevice: Device? {
        devices.first(where: { $0.id == selectedDeviceId })
    }

    private var devicesCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    public var bootedDevices: [Device] {
        devices.filter({$0.state == .booted})
    }

    init(historyStore: HistoryStore<Push>, push: Push? = nil, deviceDiscoveryManager: DeviceDiscoveryManager) {
        let push = push ?? historyStore.items.last
        
        self.historyStore = historyStore
        self.payload = push?.payload ?? ""
        self.deviceDiscoveryManager = deviceDiscoveryManager
    }

    func load() {
        deviceDiscoveryManager.startFetch(interval: 10)

        devicesCancellable = deviceDiscoveryManager.$devices
            .assign(to: \.devices, on: self)
    }

    func send() throws {
        guard
            let device = selectedDevice,
            let selectedApplication = selectedApplication
        else {
            return
        }

        Task.init {
            let push = Push(payload: payload, bundleIdentifier: selectedApplication.bundleIdentifier, date: Date())
            try await device.asyncSend(push: push)
            historyStore.store(item: push)
        }
    }

}
