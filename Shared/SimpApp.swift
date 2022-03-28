//
//  SimpApp.swift
//  Shared
//
//  Created by Mathias Amnell on 2021-03-20.
//

import SwiftUI
import SimpKit

@main
struct SimpApp: App {

    private let historyStore: HistoryStore<Push>
    private let deviceDiscoveryManager: DeviceDiscoveryManager

    init() {
        historyStore = HistoryStore<Push>()
        
        if ProcessInfo.processInfo.environment["mock_data_source"] == "true" {
            deviceDiscoveryManager = DeviceDiscoveryManager(dataSource: MockDeviceDiscoveryDataSource()) //DeviceDiscoveryManager(dataSource: FilesystemDeviceDiscoveryDataSource())
        } else {
            deviceDiscoveryManager = DeviceDiscoveryManager(dataSource: FilesystemDeviceDiscoveryDataSource())
        }
        
        deviceDiscoveryManager.startFetch(interval: 10)

        try! historyStore.load()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                DevicesView(viewModel: DevicesViewModel(deviceDiscoveryManager: deviceDiscoveryManager))
                    .navigationTitle("Devices")
                    .listStyle(.sidebar)
                
                Text("Select a device")
                
                Text("Select a device")
            }
            .environmentObject(historyStore)
            .environmentObject(deviceDiscoveryManager)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button(action: {
                    if let currentWindow = NSApp.keyWindow,
                       let windowController = currentWindow.windowController {
                        windowController.newWindowForTab(nil)
                        if let newWindow = NSApp.keyWindow,
                           currentWindow != newWindow {
                            currentWindow.addTabbedWindow(newWindow, ordered: .above)
                        }
                    }
                }) {
                    Text("New Tab")
                }
                .keyboardShortcut("t", modifiers: [.command])
            }
        }
        
    }
}
