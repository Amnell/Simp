//
//  SimPApp.swift
//  Shared
//
//  Created by Mathias Amnell on 2021-03-20.
//

import SwiftUI

@main
struct SimPApp: App {
    var body: some Scene {
        WindowGroup {
                ContentView(historyStore: HistoryStore<PayloadHistoryItem>())
        }
    }
}
