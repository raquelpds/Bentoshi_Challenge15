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
    @State private var hoveredButton: AddArtefactAction?
    @State private var isHoveringMainButton = false

    let onAction: (AddArtefactAction) -> Void

    var body: some View {
        VStack(spacing: 12) {

            if isExpanded {

                floatingButton(
                    systemImage: "folder",
                    actionType: .archive
                ) {
                    onAction(.archive)
                }

                floatingButton(
                    systemImage: "textformat.characters",
                    actionType: .text
                ) {
                    onAction(.text)
                }

                floatingButton(
                    systemImage: "link",
                    actionType: .link
                ) {
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
                    .scaleEffect(isHoveringMainButton ? 1.15 : 1.0)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    isHoveringMainButton = hovering
                }
            }
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
        actionType: AddArtefactAction,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2.weight(.bold))
                .frame(width: 50, height: 50)
                .background(Color.neutralColor1)
                .foregroundStyle(Color.buttonIcon)
                .clipShape(Circle())
                .shadow(radius: 4)
                .scaleEffect(hoveredButton == actionType ? 1.18 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                hoveredButton = hovering ? actionType : nil
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
