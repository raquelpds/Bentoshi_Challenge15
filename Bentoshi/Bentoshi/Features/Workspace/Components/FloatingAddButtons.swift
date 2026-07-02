//
//  FloatingAddButtons.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

enum AddArtefactAction {
    case archive
    case text
    case link
}

struct FloatingAddButton: View {
    @State private var isExpanded = false

    let onAction: (AddArtefactAction) -> Void

    var body: some View {
        VStack(spacing: 12) {

            if isExpanded {

                floatingButton(systemImage: "archivebox") {
                    onAction(.archive)
                }

                floatingButton(systemImage: "textformat.characters") {
                    onAction(.text)
                }

                floatingButton(systemImage: "link") {
                    onAction(.link)
                }
            }

            Button {
                isExpanded.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .frame(width: 60, height: 60)
                    .background(Color(nsColor: .controlAccentColor))
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .onHover { hovering in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isExpanded = hovering
            }
        }
    }

    private func floatingButton(
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(.gray.opacity(0.9))
                .foregroundStyle(.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .buttonStyle(.plain)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
