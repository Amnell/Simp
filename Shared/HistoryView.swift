//
//  HistoryView.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-03-21.
//

import SwiftUI

struct PayloadHistoryItem: Codable, Hashable, Equatable {
    let payload: String
    let bundleIdentifier: String
    let date: Date
}

class HistoryStore<T: Codable & Hashable>: ObservableObject {
    @Published var items: [T] = []

    private var store: [T] = []

    func store(item: T) {
        store.append(item)
    }

    func delete(item: T) {
        store.removeAll(where: { $0 == item })
    }

    func clear() {
        store.removeAll()
    }
}

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore<PayloadHistoryItem>

    var body: some View {
        ScrollView {
            HStack {
                ForEach(historyStore.items, id: \.date) { historyItem in
                    Text("\(historyItem.date)")
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
