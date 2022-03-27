//
//  HistoryStore.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-03.
//

import Foundation

@MainActor
class HistoryStore<T: Codable & Hashable & Identifiable>: ObservableObject {
    @Published var items: [T] = []

    private let limit: Int
    private let defaultLimit: Int = 20

    init(limit: Int? = nil) {
        self.limit = limit ?? defaultLimit
    }

    func store(item: T, persist: Bool = true) {
        items.append(item)
        if persist {
            try? self.persist()
        }
    }

    func delete(item: T) {
        items.removeAll(where: { $0 == item })
    }

    func clear() {
        items.removeAll()
    }

    func historyFilePath(name: String, extension withExtension: String) -> URL? {
        dotfilePath()?
            .appendingPathComponent(name)
            .appendingPathExtension(withExtension)
    }

    func dotfilePath() -> URL? {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".simp")
    }

    func createDotDir() {
        if !FileManager.default.fileExists(atPath: dotfilePath()!.path) {
            try! FileManager.default.createDirectory(at: dotfilePath()!, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func persist() throws {
        createDotDir()
        
        let cappedItems = Array(items.suffix(limit))
        
        let data = try JSONEncoder().encode(cappedItems)
        if let filePath = historyFilePath(name: "history", extension: "data") {
            FileManager.default.createFile(atPath: filePath.path, contents: data)
        }
    }

    func load() throws {
        if let filePath = historyFilePath(name: "history", extension: "data") {

            guard FileManager.default.fileExists(atPath: filePath.path) else {
                return
            }

            let data = try Data(contentsOf: filePath.standardizedFileURL)
            
            do {
                let history = try JSONDecoder().decode([T].self, from: data)

                items = history
            } catch {
                try! FileManager.default.removeItem(at: filePath)
            }
        }
    }
}

