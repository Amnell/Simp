//
//  ApplicationDiscoveryService.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-03.
//

import Foundation

protocol ApplicationDiscoveryService {
    func apps(in device: Device) async throws -> [AppData]
    func apps(in path: String) async throws -> [AppData]
}

class DefaultApplicationDiscoveryService: ApplicationDiscoveryService {
    public func apps(in device: Device) async throws -> [AppData] {
        try await apps(in: device.dataPath + "/Containers/Bundle/Application/")
    }

    public func apps(in path: String) async throws -> [AppData] {
        let content = try await Process.asyncExecute(path: URL(fileURLWithPath: "/bin/ls"),
                                                     arguments: [path, "-1q", "--color=none", "--"],
                                                     input: nil)

        return try await withThrowingTaskGroup(of: AppData.self) { taskGroup -> [AppData] in
            var apps = [AppData]()

            let rows = content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")
                .dropFirst()

            rows.forEach { appIdentifier in
                taskGroup.addTask {
                    try await DefaultApplicationDiscoveryService.app(in: path, identifier: appIdentifier)
                }
            }

            for try await appData in taskGroup {
                apps.append(appData)
            }

            return apps
        }
    }

    enum Error: Swift.Error {
        case bundleIdenfierNotFound
        case bundleNameNotFound
        case infoPlistNotFound
    }

    static func app(in path: String, identifier: String) async throws -> AppData {
        let plistPath = try await Process
            .asyncExecute(path: URL(fileURLWithPath: "/usr/bin/find"),
                          arguments: "\(path)/\(identifier) -name Info.plist -maxdepth 2")

        guard plistPath.count > 0 else {
            throw Error.infoPlistNotFound
        }

        let bundleIdentifierResult = try await Process
            .asyncExecute(path: URL(fileURLWithPath: "/usr/bin/plutil"),
                          arguments: "-extract CFBundleIdentifier xml1 -o - -- \(plistPath)")

        let bundleNameResult = try await Process
            .asyncExecute(path: URL(fileURLWithPath: "/usr/bin/plutil"),
                          arguments: "-extract CFBundleName xml1 -o - -- \(plistPath)")

        let regexp = #"<string>(.*)</string>"#
        let bundleIdentifierMatches = String.matches(for: regexp, in: bundleIdentifierResult)
        let bundleNameMatches = String.matches(for: regexp, in: bundleNameResult)

        guard bundleIdentifierMatches.count >= 2 else {
            throw Error.bundleNameNotFound
        }

        guard bundleIdentifierMatches.count >= 2 else {
            throw Error.bundleIdenfierNotFound
        }

        let bundleIdentifier = bundleIdentifierMatches[1]
        let bundleName = bundleNameMatches[1]

        return AppData(id: identifier, path: "\(path)/\(identifier)", bundleIdentifier: bundleIdentifier, name: bundleName)
    }
}

struct AppData: Equatable, Hashable, Codable {
    let id: String
    let path: String
    let bundleIdentifier: String
    let name: String
}

extension String {
    fileprivate static func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            var match = [String]()
            for result in results {
                for i in 0 ..< result.numberOfRanges {
                    match.append(nsString.substring(with: result.range(at: i)))
                }
            }
            return match
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
