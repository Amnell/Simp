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

public class ApplicationDiscoveryService {

    private static let logger = Logger(subsystem: "SimpKit", category: "ApplicationDiscoveryService")
    
    enum Error: Swift.Error {
        case bundleIdenfierNotFound
        case bundleNameNotFound
        case infoPlistNotFound
        case failedToLoadAppData
        
    
    }
    
    public init() {}
    
    public func apps(in device: Device) async throws -> [Application] {
        return await apps(in: device.dataPath + "/Containers/Bundle/Application")
    }

    public func apps(in path: String) async -> [Application] {
        await withTaskGroup(of: Application?.self, returning: [Application].self) { taskGroup in
            let content = Process.cmd("/bin/ls '\(path)' -1q --color=none --")
            var apps = [Application]()

            let rows = content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")
                .dropFirst()

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

            for await appData in taskGroup {
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
        let plistPath = Process.cmd("/usr/bin/find \(bundleDirUrl.path) -name Info.plist -maxdepth 2")
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
