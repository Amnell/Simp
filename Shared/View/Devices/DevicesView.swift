//
//  DevicesView.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2022-03-26.
//

import SwiftUI
import SimpKit
import Combine

class DevicesViewModel: ObservableObject {
    var deviceDiscoveryManager: DeviceDiscoveryManager
    
    @Published var devices: [Device] = []
    @Published var selectedDevice: Device?
    
    var bootedDevices: [Device] {
        devices.filter({ $0.state == .booted })
    }
    
    var otherDevices: [Device] {
        devices.filter({ $0.state != .booted })
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(deviceDiscoveryManager: DeviceDiscoveryManager) {
        self.deviceDiscoveryManager = deviceDiscoveryManager
        
        deviceDiscoveryManager.$devices
            .map({ $0.sorted(by: \.name) })
            .map({ $0.filter({ $0.isAvailable }) })
            .map({ $0.filter({ ($0.applications?.count ?? 0) > 0 }) })
            .receive(on: RunLoop.main)
            .assign(to: \.devices, on: self)
            .store(in: &cancellables)
    }
}

struct DevicesView: View {
    
    @StateObject var viewModel: DevicesViewModel
    @EnvironmentObject var historyStore: HistoryStore<Push>
    
    func deviceRow(device: Device) -> some View {
        NavigationLink(tag: device, selection: $viewModel.selectedDevice) {
            ApplicationsListView(device: device)
        } label: {
            DeviceRowView(device: device)
        }
    }
    
    var body: some View {
        List(selection: $viewModel.selectedDevice) {
            Section("Booted") {
                ForEach(viewModel.bootedDevices) { device in
                    deviceRow(device: device)
                }
            }
            
            Section("Other") {
                ForEach(viewModel.otherDevices) { device in
                    deviceRow(device: device)
                }
            }
        }.animation(.default, value: viewModel.devices)
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView(viewModel: DevicesViewModel(deviceDiscoveryManager: DeviceDiscoveryManager(dataSource: FilesystemDeviceDiscoveryDataSource())))
    }
}
