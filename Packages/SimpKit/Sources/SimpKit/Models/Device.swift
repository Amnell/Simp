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
    
    public enum DeviceType {
        case iphone
        case appleWatch
        case iPad
        case unknown
        
        init(string: String) {
            if string.contains("com.apple.CoreSimulator.SimDeviceType.Apple-Watch") {
                self = .appleWatch
            } else if string.contains("com.apple.CoreSimulator.SimDeviceType.iPhone") {
                self = .iphone
            } else if string.contains("com.apple.CoreSimulator.SimDeviceType.iPad") {
                self = .iPad
            } else {
                self = .unknown
            }
        }
    }

    public let dataPath: String
    public let logPath: String
    public let udid: String
    public let isAvailable: Bool
    private let deviceTypeIdentifier: String
    public let state: State
    public let name: String
    public var applications: [Application]?
    
    public var deviceype: DeviceType {
        DeviceType(string: deviceTypeIdentifier)
    }

    public var id: String {
        udid
    }
    
    public init(dataPath: String, logPath: String, udid: String, isAvailable: Bool, deviceTypeIdentifier: String, state: Device.State, name: String, applications: [Application]? = nil) {
        self.dataPath = dataPath
        self.logPath = logPath
        self.udid = udid
        self.isAvailable = isAvailable
        self.deviceTypeIdentifier = deviceTypeIdentifier
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
            deviceTypeIdentifier: \(deviceTypeIdentifier)
            state: \(state)
            name: \(name)
            applications: \(applications)
        –––––––––––––––––––––––––––––––––––––––––
        """
    }
    
}
