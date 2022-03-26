//
//  HistoryView.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-03-21.
//

import SwiftUI
import SimpKit

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore<Push>
    @EnvironmentObject var deviceDiscoveryManager: DeviceDiscoveryManager

    @State private var selectedPush: Push? = nil

    private var sortedHistoryItems: [Push] {
        historyStore.items.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        List(sortedHistoryItems) { push in
            NavigationLink(
                destination: ComposePushView(viewModel: ComposePushViewModel(historyStore: historyStore,
                                                                             push: push,
                                                                             deviceDiscoveryManager: deviceDiscoveryManager)),
                tag: push,
                selection: $selectedPush,
                label: {
                    HistoryItemRowView(historyItem: push)
                })
                .id(push)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(HistoryStore<Push>.historyItemMock)
    }
}

extension HistoryStore {
    static var historyItemMock: HistoryStore<Push> {
        let store = HistoryStore<Push>()
        store.items = [
            .init(
                payload: """
{
    "aps": {
        "alert": "Push Notifications Test",
        "sound": "default",
        "badge": 1
    }
}
""",
                bundleIdentifier: "xyz",
                date: Date().advanced(by: -10)),
            .init(
                payload: "xyz",
                bundleIdentifier: "xyz",
                date: Date().advanced(by: -5)),
            .init(
                payload: "xyz",
                bundleIdentifier: "xyz",
                date: Date().advanced(by: -4)),
            .init(
                payload: "xyz",
                bundleIdentifier: "xyz",
                date: Date().advanced(by: -2)),
        ]
        return store
    }
}
