//
//  RichTextEditor.swift
//  Chronicler
//
//  Created by Rolando on 10/6/25.
//

import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var fontSize: CGFloat
    var onTextViewCreated: ((NSTextView) -> Void)?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        textView.usesInspectorBar = false
        textView.usesFontPanel = false
        textView.textColor = NSColor.textColor
        textView.backgroundColor = .clear
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.font = NSFont(name: "Palatino", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        textView.insertionPointColor = NSColor(red: 141/255, green: 107/255, blue: 148/255, alpha: 1.0)

        textView.textStorage?.setAttributedString(attributedText)

        DispatchQueue.main.async {
            onTextViewCreated?(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        if textView.attributedString() != attributedText {
            let selectedRange = textView.selectedRange()
            textView.textStorage?.setAttributedString(attributedText)
            if selectedRange.location <= textView.string.count {
                textView.setSelectedRange(selectedRange)
            }
        }

        context.coordinator.currentFontSize = fontSize
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var currentFontSize: CGFloat

        init(_ parent: RichTextEditor) {
            self.parent = parent
            self.currentFontSize = parent.fontSize
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.attributedText = textView.attributedString()
        }
    }
}
