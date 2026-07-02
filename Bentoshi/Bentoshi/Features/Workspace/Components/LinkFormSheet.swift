//
//  LinkForm.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 23/06/26.
//

import SwiftUI

struct LinkFormSheet: View {
    
    enum Mode {
        case create
        case edit(Artefact)
        
        var title: String {
            switch self {
            case .create:
                "Adicionar link"
            case .edit:
                "Editar link"
            }
        }
        
        var initialName: String {
            switch self {
            case .create:
                return ""
            case .edit(let artefact):
                return artefact.name
            }
        }
        
        var initialUrl: String {
            switch self {
            case .create:
                return ""
            case .edit(let artefact):
                return artefact.content
            }
        }
        
        var initialKeywords: [String] {
            switch self {
            case .create:
                return []
            case .edit(let artefact):
                return artefact.getManualKeywords()
            }
        }
    }
    @State private var isHovering = false
    @State private var linkUrl: String
    @State private var name: String
    @State private var extractKeywords: [String]
    @State private var allKeywords = ""
    @State private var showKeywordsInfo = false
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    var onSave: (_ url: String, _ name: String, _ extractKeywords: [String]) -> Void
    
    init(
        mode: Mode = .create,
        onSave: @escaping (_ linkUrl: String, _ name: String, _ extractKeywords: [String]) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode.initialName)
        _linkUrl = State(initialValue: mode.initialUrl)
        _extractKeywords = State(initialValue: mode.initialKeywords)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(mode.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Área de drop
            VStack(spacing: 14) {
                
                
                Image(systemName: linkUrl.isEmpty ? "link" : "link.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(isHovering || !linkUrl.isEmpty ? .blue : .secondary)
                
                if linkUrl.isEmpty {
                    Text(isHovering ? "Solte o link aqui" : "Arraste um link")
                        .font(.body)
                } else {
                    Text(linkUrl)
                        .font(.body)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(.regularMaterial)
            .overlay {
                if isHovering || !linkUrl.isEmpty {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 2))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                }
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Exibir como:")
                    .foregroundStyle(.secondary)
                
                
                TextField("", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                    .padding(.bottom, 10)
                
                
                Text("Link (URL):")
                    .foregroundStyle(.secondary)
                
                
                TextField("https://...", text: $linkUrl)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
                    .onSubmit {
                        if canSave {
                            commitPendingKeywords()
                            onSave(linkUrl, name, extractKeywords)
                            dismiss()
                        }
                        
                    }
                    .padding(.bottom, 10)
                
                HStack {
                    Text("Palavras chave (opcional)")
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showKeywordsInfo.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showKeywordsInfo) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Separe as palavras‑chave utilizando uma vírgula comum.")
                        }
                        .padding()
                    }
                }
                
                TextField("", text: $allKeywords)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        commitPendingKeywords()
                    }
                
                FlowLayout(spacing: 8) {
                    ForEach(extractKeywords, id: \.self) { keyword in
                        HStack(spacing: 4){
                            Text(keyword)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 10))

                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.gray.opacity(0.15))
                        .clipShape(Capsule())
                        .onTapGesture {
                            extractKeywords.removeAll { $0 == keyword }
                        }
                    }
                }
                
                
                HStack {
                    Spacer()
                    
                    Button("Cancelar") {
                        dismiss()
                    }
                    
                    Button("Salvar") {
                        commitPendingKeywords()
                        onSave(linkUrl, name, extractKeywords)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                    
                }
                .padding(.top, 10)
                
            }
            
        }
        .padding(24)
        .frame(width: 400)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .dropDestination(for: URL.self) { items, _ in
            
            guard let url = items.first else {
                return false
            }
            
            linkUrl = url.absoluteString
            
            if name.isEmpty {
                name = url.host() ?? ""
            }
            
            return true
            
        } isTargeted: { hovering in
            isHovering = hovering
        }
    }
    
    var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUrl = linkUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !trimmedUrl.isEmpty
    }
    
    func commitPendingKeywords() {
        let newKeywords = allKeywords
            .split(whereSeparator: { $0 == "," || $0 == ";" })
            .map { normalizeKeyword(String($0)) }
            .filter { !$0.isEmpty }
        
        guard !newKeywords.isEmpty else { return }
        
        addKeywords(newKeywords)
        
        allKeywords = ""
    }
    
    private func addKeywords(_ newKeywords: [String]) {
        var merged = Set(extractKeywords)
        merged.formUnion(newKeywords)
        
        extractKeywords = merged
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
    private func normalizeKeyword(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return CGSize(
            width: maxWidth,
            height: y + rowHeight
        )
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

