//
//  journalentry.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//

import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    
    init(id: UUID = UUID(), title: String="", content: String="",
         createdAt: Date=Date(), modifiedAt: Date=Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    mutating func touch() {
        self.modifiedAt = Date()
    }
}

extension JournalEntry {
    static var sampleEntries: [JournalEntry] {
        [
            JournalEntry(
                title: "TEST",
                content: "Today was a great day.",
                createdAt: Date().addingTimeInterval(-86400 * 2)
            ),
            JournalEntry(
                title: "TEST TEST",
                content: "I'm not sure if I like it yet.",
                createdAt: Date().addingTimeInterval(-86400)
            ),
            JournalEntry(
                title: "TEST TEST TEST",
                content: "I think it will be.",
                createdAt: Date()
            ),
        ]
    }
}

