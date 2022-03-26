//
//  Device+AsyncSend.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2021-12-07.
//

import Foundation
import SimpKit

// MARK: Async/Await

extension Device {
    
    private func tempAPNSFile(payload: String) throws -> URL {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                        isDirectory: true)
        let temporaryFilename = ProcessInfo().globallyUniqueString + ".apns"
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        try payload.data(using: .utf8)!.write(to: temporaryFileURL, options: .atomic)
        
        return temporaryFileURL
    }
    
    @discardableResult
    func asyncSend(bundleId: String, payload: String) async throws -> String {
        let file = try tempAPNSFile(payload: payload)
        return Process.cmd("/usr/bin/xcrun simctl push \(udid) \(bundleId) \(file.path)")
    }

    @discardableResult
    func asyncSend(push: Push) async throws -> String {
        try await asyncSend(bundleId: push.bundleIdentifier, payload: push.payload)
    }
}
