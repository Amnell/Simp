//
//  Device+Extension.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-03.
//

import Foundation

struct Device: Codable, Identifiable, Hashable, Equatable {
    enum State: String, Codable {
        case shutdown = "Shutdown"
        case shuttingDown = "Shutting Down"
        case booted = "Booted"
        case creating = "Creating"
        case unknown = "unknown"
    }

    let dataPath: String
    let logPath: String
    let udid: String
    let isAvailable: Bool
    let deviceTypeIdentifier: String
    let state: State
    let name: String
    var applications: [AppData]?

    var id: String {
        udid
    }
}
