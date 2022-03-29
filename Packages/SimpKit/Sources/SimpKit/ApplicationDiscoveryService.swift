//
//  File.swift
//  
//
//  Created by Mathias Amnell on 2022-03-24.
//

import Foundation
import Combine
import AppKit
import os.log

public protocol ApplicationDiscoveryServiceType {
    func apps(in device: Device) async throws -> [Application]
    func apps(in path: String) async throws -> [Application]
}

public class ApplicationDiscoveryService: ApplicationDiscoveryServiceType {

    private static let logger = Logger(subsystem: "SimpKit", category: "ApplicationDiscoveryService")
    
    enum Error: Swift.Error {
        case bundleIdenfierNotFound
        case bundleNameNotFound
        case infoPlistNotFound
        case failedToLoadAppData
    }
    
    public init() {}
    
    public func apps(in device: Device) async throws -> [Application] {
        try await apps(in: device.dataPath + "/Containers/Bundle/Application")
    }

    public func apps(in path: String) async throws -> [Application] {
        try await withThrowingTaskGroup(of: Application?.self, returning: [Application].self) { taskGroup in
            let content = try await Process.cmd("/bin/ls", arguments:["-1q", "--color=none", "--", path])
            var apps = [Application]()
            
            let rows = content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")
                .filter { !$0.isEmpty }
            
            rows.forEach { appIdentifier in
                taskGroup.addTask {
                    do {
                        return try await ApplicationDiscoveryService.application(at: path, identifier: appIdentifier)
                    } catch {
                        Self.logger.error("Failed to create application at path: \(path) with identifier: \(appIdentifier)")
                        return nil
                    }
                }
            }

            for try await appData in taskGroup {
                guard let appData = appData else { continue }
                apps.append(appData)
            }

            return apps
        }
    }

    fileprivate static func iconUrl(_ bundleDirUrl: URL, _ appInfoDict: NSDictionary) -> URL? {
        if let contents = try? FileManager.default.contentsOfDirectory(at: bundleDirUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]) {
            if let url = contents.first(where: { $0.pathExtension == "app" }), let bundle = Bundle(url: url) {
                if let iconFiles = ((appInfoDict["CFBundleIcons"] as? NSDictionary)?["CFBundlePrimaryIcon"] as? NSDictionary)?["CFBundleIconFiles"] as? [String] {
                    for filename in iconFiles {
                        if let imageUrl = bundle.urlForImageResource(filename) {
                            return imageUrl
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    static func application(at path: String, identifier: String) async throws -> Application {
        let bundleDirUrl = URL(fileURLWithPath: "\(path)/\(identifier)")
        let plistPath = try await Process.cmd("/usr/bin/find", arguments: [bundleDirUrl.path, "-name", "Info.plist", "-maxdepth", "2"])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let plistURL = URL(fileURLWithPath: plistPath)
        
        guard
            let infoPlist = NSDictionary(contentsOf: plistURL),
            let bundleIdentifier = infoPlist["CFBundleIdentifier"] as? String,
            let bundleDisplayName = (infoPlist["CFBundleDisplayName"] as? String) ?? (infoPlist["CFBundleName"] as? String)
        else {
            throw Error.failedToLoadAppData
        }
        
        let iconUrl = iconUrl(bundleDirUrl, infoPlist)
        
        let application = Application(id: identifier,
                                      path: bundleDirUrl.path,
                                      bundleIdentifier: bundleIdentifier,
                                      name: bundleDisplayName,
                                      iconUrl: iconUrl)
        
        return application
    }
}
