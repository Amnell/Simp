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
    @ObservedObject var deviceDiscoveryManager: DeviceDiscoveryManager
    
    @Published var devices: [Device] = []
    
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
    
    @State var selectedDeviceId: String?
    
    func deviceRow(device: Device) -> some View {
        NavigationLink {
            ApplicationsListView(device: device)
        } label: {
            DeviceRowView(device: device)
        }.tag(device)
    }
    
    var body: some View {
        List(selection: $selectedDeviceId) {
            Section("Booted") {
                ForEach(viewModel.devices.filter({ $0.state == .booted })) { device in
                    deviceRow(device: device)
                        .tag(device.id)
                }
            }
            
            Section("Other") {
                ForEach(viewModel.devices.filter({ $0.state != .booted })) { device in
                    deviceRow(device: device)
                        .tag(device.id)
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
