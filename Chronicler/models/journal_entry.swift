//
//  journalentry.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//

import Foundation
import AppKit

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var song: String
    var content: String
    var attributedContent: Data?
    var createdAt: Date
    var modifiedAt: Date

    init(id: UUID = UUID(), title: String="", song: String="", content: String="", attributedContent: Data? = nil,
         createdAt: Date=Date(), modifiedAt: Date=Date()) {
        self.id = id
        self.title = title
        self.song = song
        self.content = content
        self.attributedContent = attributedContent
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        song = try container.decodeIfPresent(String.self, forKey: .song) ?? ""
        content = try container.decode(String.self, forKey: .content)
        attributedContent = try container.decodeIfPresent(Data.self, forKey: .attributedContent)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        modifiedAt = try container.decode(Date.self, forKey: .modifiedAt)
    }
    
    mutating func touch() {
        self.modifiedAt = Date()
    }
}
