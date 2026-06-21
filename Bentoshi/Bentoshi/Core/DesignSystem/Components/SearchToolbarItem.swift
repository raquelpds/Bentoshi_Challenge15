//
//  SearchToolbarItem.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftUI

struct SearchToolbarItem: View {

    @Binding var searchText: String
    @Binding var isExpanded: Bool

    @FocusState private var isSearchFocused: Bool

    var placeholder: String = "Buscar"

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 16)

            if isExpanded {
                TextField(placeholder, text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, isExpanded ? 8 : 7)
        .frame(
            width: isExpanded ? 220 : 30,
            height: 30,
            alignment: .leading
        )
        .clipShape(Capsule())
        .contentShape(Capsule())
        .overlay(alignment: .trailing) {
            if isExpanded {
                Button {
                    if searchText.isEmpty {
                        closeSearch()
                    } else {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                .transition(.opacity)
            }
        }
        .onTapGesture {
            openSearch()
        }
        .onExitCommand {
            closeSearch()
        }
        .animation(.snappy(duration: 0.25), value: isExpanded)
    }

    private func openSearch() {
        guard !isExpanded else { return }

        withAnimation(.snappy(duration: 0.25)) {
            isExpanded = true
        }

        DispatchQueue.main.async {
            isSearchFocused = true
        }
    }

    private func closeSearch() {
        searchText = ""

        withAnimation(.snappy(duration: 0.25)) {
            isExpanded = false
        }

        isSearchFocused = false
    }
}

#Preview {
    @Previewable @State var searchText = ""
    @Previewable @State var isExpanded = false

    NavigationStack {
        Text("Conteúdo")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SearchToolbarItem(
                        searchText: $searchText,
                        isExpanded: $isExpanded
                    )
                }
            }
    }
    .frame(width: 700, height: 500)
}
