//
//  EntryEditorView.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//
import SwiftUI
import AppKit

struct EntryEditorView: View {
    @EnvironmentObject var store: JournalStore
    let date: Date
    let onDismiss: () -> Void

    @State private var title: String = ""
    @State private var attributedContent: NSAttributedString = NSAttributedString(string: "")
    @State private var existingEntry: JournalEntry?
    @State private var fontSize: CGFloat = 16
    @State private var textView: NSTextView?
    
    @State private var boldEnabled: Bool = false
    @State private var italicEnabled: Bool = false
    @State private var underlineEnabled: Bool = false

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

                HStack(spacing: 12) {
                    Button(action: {
                        fontSize = max(fontSize - 2, 10)
                        updateFontSize()
                    }) {
                        Text("A").font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    .help("Decrease font size")

                    Text("\(Int(fontSize))pt")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .frame(width: 35)

                    Button(action: {
                        fontSize = min(fontSize + 2, 36)
                        updateFontSize()
                    }) {
                        Text("A").font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help("Increase font size")

                    Divider().frame(height: 20)

                    Button(action: { toggleBold() }) {
                        Image(systemName: "bold")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(boldEnabled ? Theme.Colors.buttonAccent : Color.clear, lineWidth: 2)
                    )
                    .help("Bold")

                    Button(action: { toggleItalic() }) {
                        Image(systemName: "italic")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(italicEnabled ? Theme.Colors.buttonAccent : Color.clear, lineWidth: 2)
                    )
                    .help("Italic")

                    Button(action: { toggleUnderline() }) {
                        Image(systemName: "underline")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(underlineEnabled ? Theme.Colors.buttonAccent : Color.clear, lineWidth: 2)
                    )
                    .help("Underline")

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()

                RichTextEditor(
                    attributedText: $attributedContent,
                    fontSize: fontSize,
                    onTextViewCreated: { tv in
                        self.textView = tv
                    }
                )
                .frame(minHeight: max(geometry.size.height - 250, 300))
                .padding(.horizontal, Theme.Spacing.editorPadding)

                Divider()

                HStack {
                    if !attributedContent.string.isEmpty {
                        Text("\(attributedContent.string.count) characters")
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
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    saveCurrentEntry()
                    onDismiss()
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
        .onChange(of: attributedContent.string) { _, _ in
            saveWithDebounce()
        }
    }

    private var lastSavedString: String {
        guard let entry = existingEntry else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: entry.modifiedAt, relativeTo: Date())
    }

    private func updateFontSize() {
        guard let textView = textView else { return }
        let selectedRange = textView.selectedRange()

        if selectedRange.length > 0 {
            textView.textStorage?.enumerateAttributes(in: selectedRange) { attributes, range, _ in
                var newAttributes = attributes
                if let currentFont = attributes[.font] as? NSFont {
                    let descriptor = currentFont.fontDescriptor
                    let newFont = NSFont(descriptor: descriptor, size: fontSize) ?? getSerifFont(size: fontSize)
                    newAttributes[.font] = newFont
                    textView.textStorage?.setAttributes(newAttributes, range: range)
                }
            }
        } else {
            var typingAttributes = textView.typingAttributes
            typingAttributes[.font] = getSerifFont(size: fontSize)
            textView.typingAttributes = typingAttributes
        }
    }

    private func getSerifFont(size: CGFloat, bold: Bool = false, italic: Bool = false) -> NSFont {
        var font = NSFont(name: "Palatino", size: size) ?? NSFont.systemFont(ofSize: size)

        var traits: NSFontTraitMask = []
        if bold { traits.insert(.boldFontMask) }
        if italic { traits.insert(.italicFontMask) }

        font = NSFontManager.shared.convert(font, toHaveTrait: traits)

        return font
    }


    private func toggleBold() {
        guard let textView = textView else { return }
        let selectedRange = textView.selectedRange()

        if selectedRange.length > 0 {
            textView.textStorage?.enumerateAttribute(.font, in: selectedRange) { value, range, _ in
                if let currentFont = value as? NSFont {
                    let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.bold)
                    let newFont: NSFont

                    if isBold {
                        var traits = currentFont.fontDescriptor.symbolicTraits
                        traits.remove(.bold)
                        let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                        newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? NSFont.systemFont(ofSize: currentFont.pointSize)
                    } else {
                        var traits = currentFont.fontDescriptor.symbolicTraits
                        traits.insert(.bold)
                        let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                        newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? NSFont.boldSystemFont(ofSize: currentFont.pointSize)
                    }

                    textView.textStorage?.addAttribute(.font, value: newFont, range: range)
                }
            }
        } else {
            boldEnabled.toggle()
            var typingAttributes = textView.typingAttributes
            if let currentFont = typingAttributes[.font] as? NSFont {
                let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.bold)
                let newFont: NSFont

                if isBold {
                    var traits = currentFont.fontDescriptor.symbolicTraits
                    traits.remove(.bold)
                    let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                    newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? NSFont.systemFont(ofSize: currentFont.pointSize)
                } else {
                    var traits = currentFont.fontDescriptor.symbolicTraits
                    traits.insert(.bold)
                    let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                    newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? NSFont.boldSystemFont(ofSize: currentFont.pointSize)
                }

                typingAttributes[.font] = newFont
                textView.typingAttributes = typingAttributes
            }
        }
    }

    private func toggleItalic() {
        guard let textView = textView else { return }
        let selectedRange = textView.selectedRange()

        if selectedRange.length > 0 {
            textView.textStorage?.enumerateAttribute(.font, in: selectedRange) { value, range, _ in
                if let currentFont = value as? NSFont {
                    let isItalic = currentFont.fontDescriptor.symbolicTraits.contains(.italic)
                    let newFont: NSFont

                    if isItalic {
                        var traits = currentFont.fontDescriptor.symbolicTraits
                        traits.remove(.italic)
                        let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                        newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? NSFont.systemFont(ofSize: currentFont.pointSize)
                    } else {
                        var traits = currentFont.fontDescriptor.symbolicTraits
                        traits.insert(.italic)
                        let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                        newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? currentFont
                    }

                    textView.textStorage?.addAttribute(.font, value: newFont, range: range)
                }
            }
        } else {
            italicEnabled.toggle()
            var typingAttributes = textView.typingAttributes
            if let currentFont = typingAttributes[.font] as? NSFont {
                let isItalic = currentFont.fontDescriptor.symbolicTraits.contains(.italic)
                let newFont: NSFont

                if isItalic {
                    var traits = currentFont.fontDescriptor.symbolicTraits
                    traits.remove(.italic)
                    let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                    newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? NSFont.systemFont(ofSize: currentFont.pointSize)
                } else {
                    var traits = currentFont.fontDescriptor.symbolicTraits
                    traits.insert(.italic)
                    let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits)
                    newFont = NSFont(descriptor: descriptor, size: currentFont.pointSize) ?? currentFont
                }

                typingAttributes[.font] = newFont
                textView.typingAttributes = typingAttributes
            }
        }
    }

    private func toggleUnderline() {
        guard let textView = textView else { return }
        let selectedRange = textView.selectedRange()

        if selectedRange.length > 0 {
            textView.textStorage?.enumerateAttribute(.underlineStyle, in: selectedRange) { value, range, _ in
                let currentStyle = value as? Int ?? 0
                let newStyle = currentStyle == 0 ? NSUnderlineStyle.single.rawValue : 0
                textView.textStorage?.addAttribute(.underlineStyle, value: newStyle, range: range)
            }
        } else {
            underlineEnabled.toggle()
            var typingAttributes = textView.typingAttributes
            let currentStyle = typingAttributes[.underlineStyle] as? Int ?? 0
            let newStyle = currentStyle == 0 ? NSUnderlineStyle.single.rawValue : 0
            typingAttributes[.underlineStyle] = newStyle
            textView.typingAttributes = typingAttributes
        }
    }

    private func loadEntry() {
        if let entry = store.entries.first(where: { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }) {
            existingEntry = entry
            title = entry.title

            if let data = entry.attributedContent,
               let attributed = try? NSAttributedString(data: data, documentAttributes: nil) {
                attributedContent = attributed
            } else {
                attributedContent = NSAttributedString(string: entry.content, attributes: [
                    .font: getSerifFont(size: fontSize)
                ])
            }
        } else {
            existingEntry = nil
            title = ""
            attributedContent = NSAttributedString(string: "", attributes: [
                .font: getSerifFont(size: fontSize)
            ])
        }
    }

    private func saveCurrentEntry() {
        let content = attributedContent.string
        guard !content.isEmpty || !title.isEmpty else {
            if let entry = existingEntry {
                store.deleteEntry(entry)
            }
            return
        }

        let attributedData = try? attributedContent.data(
            from: NSRange(location: 0, length: attributedContent.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )

        if var entry = existingEntry {
            entry.title = title
            entry.content = content
            entry.attributedContent = attributedData
            entry.touch()
            store.updateEntry(entry)
        } else {
            let newEntry = JournalEntry(
                title: title,
                content: content,
                attributedContent: attributedData,
                createdAt: date,
                modifiedAt: Date()
            )
            store.addEntry(newEntry)
            existingEntry = newEntry
        }
    }

    private func saveWithDebounce() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            saveCurrentEntry()
        }
    }
}

#Preview {
    NavigationStack {
        EntryEditorView(date: Date(), onDismiss: {})
            .environmentObject(JournalStore())
    }
}
