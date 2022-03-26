//
//  Device+Extension.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-03.
//

import Foundation

public struct Device: Codable, Identifiable, Hashable, Equatable {
    public enum State: String, Codable {
        case shutdown = "Shutdown"
        case shuttingDown = "Shutting Down"
        case booted = "Booted"
        case creating = "Creating"
        case unknown = "unknown"
    }

    public let dataPath: String
    public let logPath: String
    public let udid: String
    public let isAvailable: Bool
    public let deviceTypeIdentifier: String
    public let state: State
    public let name: String
    public var applications: [Application]?

    public var id: String {
        udid
    }
}

extension Device: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        """
        –––––––––––––––––––––––––––––––––––––––––
            dataPath: \(dataPath)
            logPath: \(logPath)
            udid: \(udid)
            isAvailable: \(isAvailable)
            deviceTypeIdentifier: \(deviceTypeIdentifier)
            state: \(state)
            name: \(name)
            applications: \(applications)
        –––––––––––––––––––––––––––––––––––––––––
        """
    }
    
}
