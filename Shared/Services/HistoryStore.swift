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

    func store(item: T) {
        items.append(item)
    }

    func delete(item: T) {
        items.removeAll(where: { $0 == item })
    }

    func clear() {
        items.removeAll()
    }

    func historyFilePath(name: String, extension withExtension: String) -> URL? {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".simp")
            .appendingPathComponent(name)
            .appendingPathExtension(withExtension)
    }

    func createDotDir() {
//        FileManager.default.createDirectory(at: historyFilePath(name: "history", extension: "data"), withIntermediateDirectories: <#T##Bool#>, attributes: <#T##[FileAttributeKey : Any]?#>)
    }

    func persist() throws {

        createDotDir()

        let data = try JSONEncoder().encode(items)
        if let filePath = historyFilePath(name: "history", extension: "data") {
            print(filePath)
            FileManager.default.createFile(atPath: filePath.absoluteString, contents: data, attributes: nil)
        }
    }

    func load() throws {
        if let filePath = historyFilePath(name: "history", extension: "data") {

            guard FileManager.default.fileExists(atPath: filePath.absoluteString) else {
                print("No history found")
                return
            }

            let data = try Data(contentsOf: filePath)
            do {
                let history = try JSONDecoder().decode([T].self, from: data)

                items = history
            } catch {
                try? FileManager.default.removeItem(at: filePath)
            }
        }
    }
}

