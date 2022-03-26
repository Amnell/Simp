//
//  Process+Extension.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-03-22.
//

import Foundation

extension Process {
    
    enum ProcessRunError: Swift.Error {
        case invalidPathURL
        case error(String?)
    }

    static func execute(path: URL, arguments: [String], input: String?, completion: ((Result<String, ProcessRunError>)->Void)?) throws {
        guard path.isFileURL else { throw ProcessRunError.invalidPathURL }
        
        print("💾", path.absoluteString, arguments.joined(separator: " "), input)

        let outputPipe = Pipe()
        let inputPipe = Pipe()
        let errorPipe = Pipe()

        let process = Process()

        process.executableURL = path
        process.arguments = arguments
        process.standardOutput = outputPipe.fileHandleForWriting
        process.standardInput = inputPipe
        process.standardError = errorPipe

        let group = DispatchGroup()
        group.enter()
        process.terminationHandler = { process in
            process.terminationHandler = nil
            group.leave()
        }

        if let input = input {
            let bytes: [UInt8] = Array(input.utf8)
            let fh = inputPipe.fileHandleForWriting
            fh.write(Data(bytes))
            fh.closeFile()
        }

        var standardOutData: Data?
        group.enter()
        DispatchQueue.global().async {
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            outputPipe.fileHandleForReading.closeFile()
            DispatchQueue.main.async {
                standardOutData = data
                group.leave()
            }
        }

        var errorOutData: Data?
        group.enter()
        DispatchQueue.global().async {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            errorPipe.fileHandleForReading.closeFile()
            DispatchQueue.main.async {
                errorOutData = data
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let data = errorOutData, standardOutData == nil {
                let errorString = String(data: data, encoding: .utf8)
                completion?(.failure(ProcessRunError.error(errorString)))
            }
            else if let data = standardOutData {
                if let successString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    print("🕺 successString:", successString)
                    completion?(.success(successString))
                } else {
                    completion?(.failure(ProcessRunError.error("Failed to parse success data to string")))
                }
            }
        }

        try process.run()

        outputPipe.fileHandleForWriting.closeFile()
    }
}

// MARK: Async/Await

extension Process {
    public static func cmd(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
