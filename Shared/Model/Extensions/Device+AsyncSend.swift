//
//  Device+AsyncSend.swift
//  Simp (macOS)
//
//  Created by Mathias Amnell on 2021-12-07.
//

import Foundation

// MARK: Async/Await

extension Device {
    @discardableResult
    func asyncSend(bundleId: String, payload: String) async throws -> String {
        try await Process.asyncExecute(path: URL(fileURLWithPath: "/usr/bin/xcrun"),
                                       arguments: ["simctl", "push", udid, bundleId, "-"],
                                       input: payload)
    }

    @discardableResult
    func asyncSend(push: Push) async throws -> String {
        try await asyncSend(bundleId: push.bundleIdentifier, payload: push.payload)
    }
}
