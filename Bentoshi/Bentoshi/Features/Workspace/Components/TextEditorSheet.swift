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

        var initialText: NSAttributedString {
            switch self {
            case .create:
                return NSAttributedString(string: "")
            case .edit(let artefact):
                return artefact.getFormattedText()
            }
        }
    }

    @State private var title: String
    @State private var text: NSAttributedString
    @State private var selectedRange: NSRange = .init(location: 0, length: 0)
    @StateObject private var editorContext = TextEditorContext()

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
        var onSave: (_ title: String, _ formattedText: NSAttributedString) -> Void
        var onCancel: (() -> Void)?

        init(
            mode: Mode = .create,
            onSave: @escaping (_ title: String, _ formattedText: NSAttributedString) -> Void,
            onCancel: (() -> Void)? = nil
        ) {
            self.mode = mode
            self.onSave = onSave
            self.onCancel = onCancel

            _title = State(initialValue: mode.initialTitle)
            _text = State(initialValue: mode.initialText)
        }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack {
                // Campo para digitar/editar o título do texto
                TextField("Título", text: $title)
                    .textFieldStyle(.plain)
                    .font(.largeTitle)
                    .bold()
                    .padding(10)
                    
                
                Spacer()
            }

            toolbar

            editor

            Spacer()

            footer
        }
        .padding()
    }

    private var editor: some View {
        RichTextEditor(
            text: $text,
            selectedRange: $selectedRange,
            context: editorContext
        )
        .padding(12)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var toolbar: some View {
        HStack(spacing: 4) {
            // Estilos Inline (Negrito, Itálico, Tachado)
            HStack(spacing: 2) {
                formatIconButton("bold", systemImage: "bold") { applyBold() }
                formatIconButton("italic", systemImage: "italic") { applyItalic() }
                formatIconButton("strikethrough", systemImage: "strikethrough") { applyStrike() }
            }
            .padding(2)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Divider().frame(height: 16)

            // Menu Dropdown para Formatações de Bloco (Poupe espaço de tela!)
            Menu {
                Button("Título Principal") { applyTitle() }
                Button("Título") { applyHeading() }
                Button("Subtítulo") { applySubheading() }
                Button("Corpo") { applyBody() }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "textformat.size")
                    Text("Formato")
                        .font(.system(size: 12))
                }
            }
            .menuStyle(.borderlessButton)
            .frame(width: 90)

            Divider().frame(height: 16)

            // Listas e Marcadores
            HStack(spacing: 2) {
                formatIconButton("bullet", systemImage: "list.bullet") { insertBullet() }
                formatIconButton("dash", systemImage: "minus") { insertDash() }
                formatIconButton("number", systemImage: "list.number") { insertNumberedList() }
            }
            .padding(2)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Spacer()
        }
        .padding(6)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Spacer()
            
            Button("Cancelar") {
                cancelAction()
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)

            Button("Salvar") {
                onSave(title, text)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func cancelAction() {
        if let onCancel = onCancel {
            onCancel()
        }
        dismiss()
    }

    // Helper para botões de ícone ultra-compactos e limpos
    private func formatIconButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 24, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func applyBold() {
        guard let textView = editorContext.textView else { return }
        let range = selectedRange
        guard range.length > 0 else { return }
        
        textView.textStorage?.enumerateAttribute(.font, in: range) { value, subrange, _ in
            let currentFont = value as? NSFont ?? .systemFont(ofSize: 13)
            
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
            let currentFont = value as? NSFont ?? .systemFont(ofSize: 13)
            
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
            ofSize: 26,
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
            ofSize: 21,
            weight: .bold
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
            ofSize: 15,
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
            ofSize: 13,
            weight: .regular
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
}
