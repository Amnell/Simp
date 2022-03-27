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
    @ObservedObject var historyStore: HistoryStore<Push>
    
    @Published var payload: String = ""
    
    @Published private(set) var device: Device
    @Published private(set) var application: Application
    
    init(device: Device, application: Application, push: Push? = nil, historyStore: HistoryStore<Push>) {
        let push = push ?? historyStore.items.last
        self.device = device
        self.application = application
        self.historyStore = historyStore
        self.payload = push?.payload ?? ""
    }

    func send() throws {
        Task.init {
            let push = Push(payload: payload, bundleIdentifier: application.bundleIdentifier, date: Date())
            try await device.asyncSend(push: push)
            historyStore.store(item: push)
        }
    }

}
