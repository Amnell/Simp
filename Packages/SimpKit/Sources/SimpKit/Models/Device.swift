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
    
    public enum DeviceType: String, CaseIterable, Codable {
        case iPhone = "Apple-Watch"
        case appleWatch = "iPhone"
        case iPad = "iPad"
        case unknown = "unknown"
        
        public init(rawValue: String) {
            self = Self.allCases.first(where: { rawValue.contains($0.rawValue) }) ?? .unknown
        }
    }

    public let dataPath: String
    public let logPath: String
    public let udid: String
    public let isAvailable: Bool
    public let deviceType: DeviceType
    public let state: State
    public let name: String
    public var applications: [Application]?
    
    public var id: String {
        udid
    }
    
    enum CodingKeys: String, CodingKey {
        case dataPath, logPath, udid, isAvailable, deviceType = "deviceTypeIdentifier", state, name
    }
    
    public init(dataPath: String, logPath: String, udid: String, isAvailable: Bool, deviceType: DeviceType, state: Device.State, name: String, applications: [Application]?) {
        self.dataPath = dataPath
        self.logPath = logPath
        self.udid = udid
        self.isAvailable = isAvailable
        self.deviceType = deviceType
        self.state = state
        self.name = name
        self.applications = applications
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
            deviceType: \(deviceType.rawValue)
            state: \(state)
            name: \(name)
            applications: \(applications ?? [])
        –––––––––––––––––––––––––––––––––––––––––
        """
    }
    
}
