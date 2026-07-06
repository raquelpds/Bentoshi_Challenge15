//
//  ArtefactCard.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct ArtefactCard: View {
    
    @Environment(\.colorScheme) private var colorScheme

    let workspaceColor: WorkspaceColor
    let artefactType: ArtefactType

    let name: String
    let backgroundColor: Color
    let showsRevealInFinder: Bool
    let preview: ArtefactPreview

    let onOpen: () -> Void
    let onUpdate: () -> Void
    let onDelete: () -> Void
    let onRevealInFinder: () -> Void

    let onResizeChanged: (CGSize) -> Void
    let onResizeEnded: (CGSize) -> Void

    @State private var isHovering = false
    let showsHoverOverlay: Bool
    
    private var artefactStrokeColor: Color {
        ArtefactColorPalette.color(
            for: artefactType,
            workspaceBaseColor: workspaceColor,
            scheme: colorScheme
        )
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)

            preview
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )

            if showsHoverOverlay && isHovering {
                hoverOverlay
                    .allowsHitTesting(false)
            }

//            resizeHandle
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
        .clipped()
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(artefactStrokeColor, lineWidth: 4)
        }
        .overlay {
            if showsHoverOverlay && isHovering {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(
                        .white.opacity(0.5),
                        lineWidth: 2
                    )
            }
        }
        .overlay(alignment: .bottomTrailing) {
            resizeHandle
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            guard showsHoverOverlay else { return }

            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            onOpen()
        }
        .contextMenu {
            Button("Abrir") {
                onOpen()
            }

            Button("Editar") {
                onUpdate()
            }

            if showsRevealInFinder {
                Button("Mostrar no Finder") {
                    onRevealInFinder()
                }
            }

            Divider()

            Button(
                "Excluir",
                role: .destructive
            ) {
                onDelete()
            }
        }
    }

    private var resizeHandle: some View {
        ZStack(alignment: .bottomTrailing) {
            ResizeCornerHandle()
                .stroke(WorkspaceColorPalette.color(for: workspaceColor, scheme: colorScheme),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .frame(width: 36, height: 36)
                .padding(.trailing, -4)
                .padding(.bottom, -4)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .onHover { hovering in
            if hovering {
                NSCursor.resizeLeftRight.push()
            } else {
                NSCursor.pop()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    onResizeChanged(value.translation)
                }
                .onEnded { value in
                    onResizeEnded(value.translation)
                }
        )
    }
    
    private var hoverOverlay: some View {
        VStack {
            Spacer()

            ZStack(alignment: .leading) {
                Color.black.opacity(0.4)

                Text(name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
            }
            .frame(height: 48)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottom
        )
        .transition(
            .move(edge: .bottom).combined(with: .opacity)
        )
    }
}

struct ResizeCornerHandle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cornerRadius: CGFloat = 15
        let horizontalLength: CGFloat = 26
        let verticalLength: CGFloat = 26

        let maxX = rect.maxX
        let maxY = rect.maxY

        path.move(
            to: CGPoint(
                x: maxX - horizontalLength,
                y: maxY
            )
        )

        path.addLine(
            to: CGPoint(
                x: maxX - cornerRadius,
                y: maxY
            )
        )

        path.addQuadCurve(
            to: CGPoint(
                x: maxX,
                y: maxY - cornerRadius
            ),
            control: CGPoint(
                x: maxX,
                y: maxY
            )
        )

        path.addLine(
            to: CGPoint(
                x: maxX,
                y: maxY - verticalLength
            )
        )

        return path
    }
}

