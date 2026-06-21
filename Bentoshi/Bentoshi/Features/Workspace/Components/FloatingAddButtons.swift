//
//  FloatingAddButtons.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct FloatingAddButton: View {
    @State private var isExpanded = false
    @Binding var showFilePicker: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 12) {
                if isExpanded {
                    floatingButton(systemImage: "archivebox") {
                        showFilePicker = true
                    }

                    floatingButton(systemImage: "textformat.characters") {
                        //
                    }

                    floatingButton(systemImage: "link") {
                        //
                    }
                }

                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(.blue)
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
