//
//  EntryEditorView.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//
import SwiftUI

struct EntryEditorView: View {
    @EnvironmentObject var store: JournalStore
    @Environment(\.dismiss) var dismiss
    let date: Date
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var existingEntry: JournalEntry?
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(dateString)
                .font(.title2)
                .foregroundColor(.secondary)
                .padding()
            
            TextField("Entry title", text: $title)
                .font(.title)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom)
            
            Divider()
            
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }
                
                TextEditor(text: $content)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            HStack {
                if !content.isEmpty {
                    Text("\(content.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if existingEntry != nil {
                    Text("Last saved: \(lastSavedString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    saveCurrentEntry()
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Calendar")
                    }
                }
            }
        }
        .onAppear {
            loadEntry()
        }
        .onChange(of: title) { _, _ in
            saveWithDebounce()
        }
        .onChange(of: content) { _, _ in
            saveWithDebounce()
        }
    }
    
    private var lastSavedString: String {
        guard let entry = existingEntry else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: entry.modifiedAt, relativeTo: Date())
    }
    
    private func loadEntry() {
        if let entry = store.entries.first(where: { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }) {
            existingEntry = entry
            title = entry.title
            content = entry.content
        } else {
            existingEntry = nil
            title = ""
            content = ""
        }
    }
    
    private func saveCurrentEntry() {
        guard !content.isEmpty || !title.isEmpty else {
            if let entry = existingEntry {
                store.deleteEntry(entry)
            }
            return
        }
        
        if var entry = existingEntry {
            entry.title = title
            entry.content = content
            entry.touch()
            store.updateEntry(entry)
        } else {
            let newEntry = JournalEntry(
                title: title,
                content: content,
                createdAt: date,
                modifiedAt: Date()
            )
            store.addEntry(newEntry)
            existingEntry = newEntry
        }
    }
    
    private func saveWithDebounce() {
        // Debounce for discrete saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            saveCurrentEntry()
        }
    }
}

#Preview {
    NavigationStack {
        EntryEditorView(date: Date())
            .environmentObject(JournalStore())
    }
}
