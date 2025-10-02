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
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Text(dateString)
                    .font(Theme.Fonts.entryDate)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .padding()
                
                TextField("Entry title", text: $title)
                    .font(Theme.Fonts.entryTitle)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                Divider()
                
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("")
                                .foregroundColor(.secondary)
                                .padding(20)
                        }
                        
                        TextEditor(text: $content)
                            .font(Theme.Fonts.entryContent)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, Theme.Spacing.editorPadding)
                            .padding(.top, 12)
                            .frame(minHeight: max(geometry.size.height - 200, 300))
                    }
                }
                
                Divider()
                
                HStack {
                    if !content.isEmpty {
                        Text("\(content.count) characters")
                            .font(Theme.Fonts.statusBar)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    if existingEntry != nil {
                        Text("Last saved: \(lastSavedString)")
                            .font(Theme.Fonts.statusBar)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
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
