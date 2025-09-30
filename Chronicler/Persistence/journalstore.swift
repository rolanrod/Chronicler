//
//  journalstore.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//

import Foundation

class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = []
    private let fileManager = FileManager.default
    
    // Currently, I have no intent to actually publish something like this to the App Store, so I intned to just use persistence via a user's disk with all entries stored in the below JSON file.
    private let fileName = "journal_entries.json"
    
    private var fileURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
              return nil
          }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    init() {
        loadEntries()
    }
    
    // Public methods //
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        entries.sort { $0.createdAt > $1.createdAt} // Newest first, top down
        saveEntries()
    }
    
    func updateEntry(_ old_entry_index: Int, _ new_entry: JournalEntry) {
        entries[index] = entry
        saveEntries()
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id}
        saveEtries()
    }
    
    // Private methods //
    private func loadEntries() {
        guard let fileURL = fileURL else {
            print("Could not find file URL!)
            return
        }
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("No saved entries found!")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            entries = try decoder.decode([JournalEntry].self, from: data)
            print("Successfully loaded \(entries.count) entries")
        } catch {
            print("Error loading entries: \(error.localizedDescription)")
        }
    }
    
    private func saveEntries() {
        guard let fileURL = fileURL else {
            print("Could not get file URL for saving")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(entries)
            try data.write(to: fileURL, options: .atomic)
            print("Successfully saved \(entries.count) entries to \(fileURL.path)")
        } catch {
            print("Error savign entries: \(error.localizedDescription)")
        }
    }
}
