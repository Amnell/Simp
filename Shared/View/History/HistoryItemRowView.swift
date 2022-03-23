//
//  HistoryItemRowView.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-02.
//

import SwiftUI

struct HistoryItemRowView: View {

    let historyItem: Push

    var body: some View {
        VStack(alignment: .leading) {
            Text(historyItem.date.timeAgoFormat())
        }
    }
}

struct HistoryItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryItemRowView(historyItem: Push(payload: "payload", bundleIdentifier: "bundleIdentifier", date: Date()))
    }
}
