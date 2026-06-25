//
//  TextEditorSheet.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI
import AppKit

struct TextEditorSheet: View {

    // MARK: - Mode
    enum Mode {
        case create
        case edit(Artefact)

        var title: String {
            switch self {
            case .create: return "Novo texto"
            case .edit: return "Editar texto"
            }
        }
        
        var initialTitle: String {
            switch self {
            case .create: return ""
            case .edit(let artefact): return artefact.name
            }
        }

        var initialContent: String {
            switch self {
            case .create: return ""
            case .edit(let artefact): return artefact.content
            }
        }
    }

    @State private var title: String
    @State private var text: NSAttributedString
    @State private var selectedRange: NSRange = .init(location: 0, length: 0)
    @StateObject private var editorContext = TextEditorContext()

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    var onSave: (_ title: String, _ content: String) -> Void

    init(
        mode: Mode = .create,
        onSave: @escaping (_ title: String, _ content: String) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave

        _title = State(initialValue: mode.initialTitle)
        _text = State(
            initialValue: Self.markdownToAttributed(
                mode.initialContent
            )
        )
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(mode.title)
                .font(.title2)
                .fontWeight(.semibold)

            // Campo para digitar/editar o título do texto
            TextField("Título do texto", text: $title)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))
                .padding(.horizontal, 2)

            toolbar

            editor

            Spacer()

            footer
        }
        .padding()
        .frame(width: 760, height: 560)
    }

    private var editor: some View {
        RichTextEditor(
            text: $text,
            selectedRange: $selectedRange,
            context: editorContext
        )
        .padding(12)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            formatButton("B") { applyBold() }
            formatButton("I") { applyItalic() }
            formatButton("S") { applyStrike() }

            Divider().frame(height: 20)

            formatButton("Title") { applyTitle() }
            
            formatButton("Heading") { applyHeading() }
            
            formatButton("Subheading") { applySubheading() }
            
            formatButton("Body") { applyBody() }

            Divider().frame(height: 20)

            formatButton("•") { insertBullet() }
            formatButton("-") { insertDash() }
            formatButton("1.") { insertNumberedList() }

            Spacer()
        }
        .padding(10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var footer: some View {
        HStack {
            Button("Cancelar") {
                dismiss()
            }

            Spacer()

            Button("Salvar") {
                // Passando o título e o conteúdo em markdown agora que o fechamento exige ambos
                onSave(title, Self.attributedToMarkdown(text))
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Opcional: Desabilita se o título estiver vazio
        }
    }

    private func formatButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func applyBold() {
        guard let textView = editorContext.textView else { return }
        let range = selectedRange
        guard range.length > 0 else { return }
        
        textView.textStorage?.enumerateAttribute(.font, in: range) { value, subrange, _ in
            let currentFont = value as? NSFont ?? .systemFont(ofSize: 16)
            
            let isBold = NSFontManager.shared.traits(of: currentFont).contains(.boldFontMask)
            
            let newFont: NSFont
            if isBold {
                newFont = NSFontManager.shared.convert(currentFont, toNotHaveTrait: .boldFontMask)
            } else {
                newFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .boldFontMask)
            }
            textView.textStorage?.addAttribute(.font, value: newFont, range: subrange)
        }
        sync()
    }

    private func applyItalic() {
        guard let textView = editorContext.textView else { return }
        let range = selectedRange
        guard range.length > 0 else { return }

        textView.textStorage?.enumerateAttribute(.font, in: range) { value, subrange, _ in
            let currentFont = value as? NSFont ?? .systemFont(ofSize: 16)
            
            let isItalic = NSFontManager.shared.traits(of: currentFont).contains(.italicFontMask)
            
            let newFont: NSFont
            
            if isItalic {
                newFont = NSFontManager.shared.convert(currentFont, toNotHaveTrait: .italicFontMask)
            } else {
                newFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .italicFontMask)
            }
            
            textView.textStorage?.addAttribute(.font, value: newFont, range: subrange)
        }
        sync()
    }

    private func applyStrike() {
        guard let textView = editorContext.textView else { return }
        let range = selectedRange
        guard range.length > 0 else { return }

        let textStorage = textView.textStorage!

        var allStriked = true

        textStorage.enumerateAttribute(.strikethroughStyle, in: range) { value, _, stop in
            let style = value as? Int ?? 0

            if style == 0 {
                allStriked = false
                stop.pointee = true
            }
        }

        if allStriked {
            textStorage.removeAttribute(.strikethroughStyle, range: range)
        } else {
            textStorage.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
        }

        sync()
    }
    
    private func applyTitle() {
        guard let textView = editorContext.textView else { return }

        let range = selectedRange
        guard range.length > 0 else { return }

        let titleFont = NSFont.systemFont(
            ofSize: 24,
            weight: .bold
        )

        textView.textStorage?.addAttribute(
            .font,
            value: titleFont,
            range: range
        )

        sync()
    }
    
    private func applyHeading() {
        guard let textView = editorContext.textView else { return }

        let range = selectedRange
        guard range.length > 0 else { return }

        let headingFont = NSFont.systemFont(
            ofSize: 16,
            weight: .heavy
        )

        textView.textStorage?.addAttribute(
            .font,
            value: headingFont,
            range: range
        )

        sync()
    }
    
    private func applySubheading() {
        guard let textView = editorContext.textView else { return }

        let range = selectedRange
        guard range.length > 0 else { return }

        let subheadingFont = NSFont.systemFont(
            ofSize: 14,
            weight: .semibold
        )

        textView.textStorage?.addAttribute(
            .font,
            value: subheadingFont,
            range: range
        )

        sync()
    }
    
    private func applyBody() {
        guard let textView = editorContext.textView else { return }

        let range = selectedRange
        guard range.length > 0 else { return }

        let subheadingFont = NSFont.systemFont(
            ofSize: 16,
            weight: .semibold
        )

        textView.textStorage?.addAttribute(
            .font,
            value: subheadingFont,
            range: range
        )

        sync()
    }

    private func insertBullet() {
        guard let textView = editorContext.textView else { return }
        
        let range = textView.selectedRange()
        let selectedText = (textView.string as NSString).substring(with: range)
        
        if !selectedText.hasPrefix("•") {
            let prefix = selectedRange.location == 0 ? "• \(selectedText)" : "\n• "
            textView.insertText(prefix, replacementRange: selectedRange)
        }
        
        sync()
    }

    private func insertDash() {
        guard let textView = editorContext.textView else { return }
        
        let range = textView.selectedRange()
        let selectedText = (textView.string as NSString).substring(with: range)
        
        if !selectedText.hasPrefix("-") {
            let prefix = selectedRange.location == 0 ? "- \(selectedText)" : "\n- "
            textView.insertText(prefix, replacementRange: selectedRange)
        }
        
        sync()
    }
    
    private func insertNumberedList() {
        guard let textView = editorContext.textView else { return }

        let range = textView.selectedRange()
        let selectedText = (textView.string as NSString).substring(with: range)

        let replacement: String

        if selectedText.isEmpty {
            replacement = selectedRange.location == 0 ? "1. " : "\n1. "
        } else {
            replacement = "1. \(selectedText)"
        }

        textView.insertText(replacement, replacementRange: range)

        sync()
    }
    
    private func sync() {
        guard let textView = editorContext.textView else { return }
        text = textView.attributedString()
    }

    static func markdownToAttributed(_ markdown: String) -> NSAttributedString {
        (try? AttributedString(markdown: markdown))
            .map { NSAttributedString($0) }
        ?? NSAttributedString(string: markdown)
    }

    static func attributedToMarkdown(_ attributed: NSAttributedString) -> String {
        attributed.string
    }
}

