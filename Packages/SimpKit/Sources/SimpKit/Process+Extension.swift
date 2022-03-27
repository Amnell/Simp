//
//  Process+Extension.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-03-22.
//

import Foundation

// MARK: Async/Await

extension Process {
    @discardableResult
    public static func cmd(_ command: String, arguments: [String]) async throws -> String {
        let command = command.appending(arguments: arguments)
        return try await cmd(command)
    }
    
    @discardableResult
    public static func cmd(_ command: String) async throws -> String {
        let process = Process()
        
        let successPipe = Pipe()
        let successFileReadHandle = successPipe.fileHandleForReading
        
        let errorPipe = Pipe()
        
        process.standardOutput = successPipe
        process.standardError = errorPipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/sh"
        
        do {
            try process.run()
        } catch {
            assertionFailure("error: \(error)")
            throw error
        }
        
        let successData = successFileReadHandle.readDataToEndOfFile()
        try? successFileReadHandle.close()
        
        return successData.output()
    }
}

private extension String {
    var escapingSpaces: String {
        return replacingOccurrences(of: " ", with: "\\ ")
    }

    func appending(argument: String) -> String {
        return "\(self) \"\(argument)\""
    }

    func appending(arguments: [String]) -> String {
        return appending(argument: arguments.joined(separator: "\" \""))
    }

    mutating func append(argument: String) {
        self = appending(argument: argument)
    }

    mutating func append(arguments: [String]) {
        self = appending(arguments: arguments)
    }
}

private extension Data {
    func output() -> String {
        guard let output = String(data: self, encoding: .utf8) else {
            return ""
        }

        guard !output.hasSuffix("\n") else {
            let endIndex = output.index(before: output.endIndex)
            return String(output[..<endIndex])
        }

        return output

    }
}
