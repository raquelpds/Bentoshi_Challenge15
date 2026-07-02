//
//  RichTextEditor.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI
import AppKit
import Combine

final class TextEditorContext: ObservableObject {
    weak var textView: NSTextView?
}

struct RichTextEditor: NSViewRepresentable {
    @Binding var text: NSAttributedString
    @Binding var selectedRange: NSRange
    
    let context: TextEditorContext

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // Evita atualizar se o conteúdo for idêntico para não quebrar o histórico de Undo
            if parent.text != textView.attributedString() {
                parent.text = textView.attributedString()
            }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            DispatchQueue.main.async {
                self.parent.selectedRange = textView.selectedRange()
            }
        }
        
        func textView(
            _ textView: NSTextView,
            doCommandBy commandSelector: Selector
        ) -> Bool {

            guard commandSelector == #selector(NSResponder.insertNewline(_:)) else {
                return false
            }

            let text = textView.string
            let cursorLocation = textView.selectedRange().location

            let nsText = text as NSString

            let safeLocation = max(cursorLocation - 1, 0)
            let lineRange = nsText.lineRange(
                for: NSRange(location: safeLocation, length: 0)
            )

            let currentLine = nsText.substring(with: lineRange)
            let trimmedLine = currentLine.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            // Bullet
            if trimmedLine == "•" {
                textView.insertText("\n", replacementRange: textView.selectedRange())
                return true
            }

            if trimmedLine.hasPrefix("• ") {
                textView.insertText("\n• ", replacementRange: textView.selectedRange())
                return true
            }

            // Dash
            if trimmedLine == "-" {
                textView.insertText("\n", replacementRange: textView.selectedRange())
                return true
            }

            if trimmedLine.hasPrefix("- ") {
                textView.insertText("\n- ", replacementRange: textView.selectedRange())
                return true
            }

            // Numbered List
            let pattern = #"^(\d+)\.\s?(.*)$"#

            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(
                    in: trimmedLine,
                    range: NSRange(location: 0, length: trimmedLine.utf16.count)
               ) {

                let numberRange = match.range(at: 1)

                if let swiftRange = Range(numberRange, in: trimmedLine),
                   let number = Int(trimmedLine[swiftRange]) {

                    let contentRange = match.range(at: 2)
                    let content = Range(contentRange, in: trimmedLine)
                        .map { String(trimmedLine[$0]) } ?? ""

                    if content.trimmingCharacters(in: .whitespaces).isEmpty {
                        textView.insertText(
                            "\n",
                            replacementRange: textView.selectedRange()
                        )
                        return true
                    }

                    // Continua a numeração
                    textView.insertText(
                        "\n\(number + 1). ",
                        replacementRange: textView.selectedRange()
                    )
                    return true
                }
            }

            return false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true

        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.usesFontPanel = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.textStorage?.setAttributedString(text)
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.font = .systemFont(ofSize: 13)
        textView.insertionPointColor = .controlAccentColor
        
        // Guarda a referência do textView de forma segura no contexto compartilhado
        self.context.textView = textView

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        // Sincroniza apenas se a string bruta mudar (evita loops com atributos visuais)
        if !textView.attributedString().isEqual(to: text) {
            textView.textStorage?.setAttributedString(text)
        }
    }
}
