//
//  SimpApp.swift
//  Shared
//
//  Created by Mathias Amnell on 2021-03-20.
//

import SwiftUI

@main
struct SimpApp: App {

    private let historyStore: HistoryStore<Push>
    private let deviceDiscoveryService: DeviceDiscoveryService

    init() {
        historyStore = HistoryStore<Push>.historyItemMock
        deviceDiscoveryService = DeviceDiscoveryService(appDiscoveryService: DefaultApplicationDiscoveryService())

        try! historyStore.persist()
        try! historyStore.load()
    }

    var body: some Scene {
        WindowGroup {
            ComposePushView(viewModel: ComposePushViewModel(historyStore: historyStore, deviceDiscoveryService: deviceDiscoveryService))
            .environmentObject(historyStore)
            .environmentObject(deviceDiscoveryService)
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
