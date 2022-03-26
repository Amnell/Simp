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
}

extension Application: Identifiable {
    
}
