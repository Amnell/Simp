//
//  Date+RelativeTime.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-02.
//

import Foundation

extension Date {
    func timeAgoFormat() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .listItem
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
