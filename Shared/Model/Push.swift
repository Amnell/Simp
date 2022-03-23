//
//  Push.swift
//  Simp
//
//  Created by Mathias Amnell on 2021-12-03.
//

import Foundation

struct Push: Codable, Hashable, Equatable {
    let payload: String
    let bundleIdentifier: String
    let date: Date
}

extension Push: Identifiable {
    var id: Date {
        date
    }
}
