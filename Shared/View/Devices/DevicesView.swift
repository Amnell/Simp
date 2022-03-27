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
            .receive(on: RunLoop.main)
            .assign(to: \.devices, on: self)
            .store(in: &cancellables)
    }
}

struct DevicesView: View {
    
    @StateObject var viewModel: DevicesViewModel
    @EnvironmentObject var historyStore: HistoryStore<Push>
    @EnvironmentObject var deviceDiscoveryManager: DeviceDiscoveryManager
    
    func deviceRow(device: Device) -> some View {
        NavigationLink {
            ApplicationsListView(device: device)
        } label: {
            DeviceRowView(device: device)
        }.tag(device)
    }
    
    var body: some View {
        List {
            Section("Booted") {
                ForEach(viewModel.devices.filter({ $0.state == .booted })) { device in
                    deviceRow(device: device)
                }
            }
            
            Section("Other") {
                ForEach(viewModel.devices.filter({ $0.state != .booted })) { device in
                    deviceRow(device: device)
                }
            }
        }
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView(viewModel: DevicesViewModel(deviceDiscoveryManager: DeviceDiscoveryManager()))
    }
}
