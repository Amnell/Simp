//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-24.
//

import Foundation
import AppKit

public struct Application: Equatable, Hashable, Codable {
    public let id: String
    public let path: String
    public let bundleIdentifier: String
    public let name: String
    public let iconUrl: URL?
    
    public var icon: NSImage? {
        guard let iconUrl = iconUrl else {
            return nil
        }
        
        return NSImage(byReferencing: iconUrl)
    }
    
    public init(id: String, path: String, bundleIdentifier: String, name: String, iconUrl: URL?) {
        self.id = id
        self.path = path
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.iconUrl = iconUrl
    }
}

extension Application: Identifiable {
    
}
