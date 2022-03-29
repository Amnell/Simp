//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-28.
//

import Foundation
import AppKit

extension Device {
    
    public static func mock() -> [Device] {
        [
            .init(dataPath: "", logPath: "", udid: "1FD268DB-C2F3-4C1A-A822-748AB49AC601", isAvailable: true, deviceType: .iPhone, state: .booted, name: "iPhone 13 Pro", applications: Application.mockCollection1()),
            .init(dataPath: "", logPath: "", udid: "70E77384-2F0E-420F-8C35-2C953276C252", isAvailable: true, deviceType: .iPhone, state: .booted, name: "iPhone 12", applications: Application.mockCollection2()),
            .init(dataPath: "", logPath: "", udid: "E412F72A-005B-4BDA-B65D-E218E89FD6F8", isAvailable: true, deviceType: .iPhone, state: .shuttingDown, name: "iPhone 7", applications: Application.mockCollection3()),
            .init(dataPath: "", logPath: "", udid: "1EB6BC4A-EA45-4C58-8250-4426D7D08369", isAvailable: true, deviceType: .iPhone, state: .shutdown, name: "iPad", applications: Application.mockCollection1()),
        ]
        
    }
    
}

extension Application {
    public static func mockCollection1() -> [Application] {
        return [
            .init(id: "914E8DE1-F5B7-4E9D-8FBB-2D608DCA6917",
                  path: "",
                  bundleIdentifier: "com.simp.bundldeIdentifier1",
                  name: "Fakebook",
                  iconUrl: Bundle.module.url(forResource: "app.icon.1", withExtension: "jpeg")),
            .init(id: "294CFE17-E0CC-4DB9-B621-27640FA9F00F",
                  path: "",
                  bundleIdentifier: "com.simp.bundldeIdentifier2",
                  name: "Tinderer",
                  iconUrl: Bundle.module.url(forResource: "app.icon.2", withExtension: "jpeg")),
            .init(id: "8A17EA93-3997-4D54-B71E-744464865D98",
                  path: "",
                  bundleIdentifier: "com.simp.bundldeIdentifier3",
                  name: "Instagrum",
                  iconUrl: Bundle.module.url(forResource: "app.icon.3", withExtension: "jpeg"))
        ]
    }
    
    public static func mockCollection2() -> [Application] {
        return [
            .init(id: "914E8DE1-F5B7-4E9D-8FBB-2D608DCA6917",
                  path: "",
                  bundleIdentifier: "com.simp.bundldeIdentifier1",
                  name: "Fakebook",
                  iconUrl: Bundle.module.url(forResource: "app.icon.1", withExtension: "jpeg"))
        ]
    }
    
    public static func mockCollection3() -> [Application] {
        return [
            .init(id: "294CFE17-E0CC-4DB9-B621-27640FA9F00F",
                  path: "",
                  bundleIdentifier: "com.simp.bundldeIdentifier2",
                  name: "Tinderer",
                  iconUrl: Bundle.module.url(forResource: "app.icon.2", withExtension: "jpeg")),
            .init(id: "8A17EA93-3997-4D54-B71E-744464865D98",
                  path: "",
                  bundleIdentifier: "com.simp.bundldeIdentifier3",
                  name: "Instagrum",
                  iconUrl: Bundle.module.url(forResource: "app.icon.3", withExtension: "jpeg"))
        ]
    }
    
}
