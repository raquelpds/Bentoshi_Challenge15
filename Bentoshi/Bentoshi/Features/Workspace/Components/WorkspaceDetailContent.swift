//
//  WorkspaceDetailContent.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI
import SwiftData

struct WorkspaceDetailContent: View {

    @Environment(\.modelContext)
    private var modelContext

    let workspace: Workspace
    let presenter: WorkspacePresenter

    @Binding var route: WorkspaceRoute?
    @Binding var alert: WorkspaceAlert?

    private let cellSize: CGFloat = 60

    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var resizeOffsets: [UUID: CGSize] = [:]

    var body: some View {

        ScrollView([.horizontal, .vertical]) {

            ZStack(alignment: .topLeading) {

                GridBackground(
                    rows: 25,
                    columns: 25
                )

                ForEach(workspace.artefacts) { artefact in

                    let resizeOffset =
                        resizeOffsets[artefact.id]
                        ?? .zero

                    let previewWidth =
                        CGFloat(
                            max(
                                1,
                                artefact.width
                                +
                                Int(
                                    (
                                        resizeOffset.width
                                        / cellSize
                                    ).rounded()
                                )
                            )
                        ) * cellSize

                    let previewHeight =
                        CGFloat(
                            max(
                                1,
                                artefact.height
                                +
                                Int(
                                    (
                                        resizeOffset.height
                                        / cellSize
                                    ).rounded()
                                )
                            )
                        ) * cellSize

                    let displayedWidth =
                        resizeOffset == .zero
                        ? CGFloat(artefact.width) * cellSize
                        : previewWidth

                    let displayedHeight =
                        resizeOffset == .zero
                        ? CGFloat(artefact.height) * cellSize
                        : previewHeight

                    ArtefactCard(
                        artefact: artefact,
                        pallete: workspace.coverColor,
                        
                    ) {
                        if isValid(artefact) {
                            presenter.open(artefact)
                        }
                    } onUpdate: {
                        handleUpdate(artefact: artefact)
                    } onDelete: {
                        alert = .deleteArtefact(artefact)
                    } onRevealInFinder: {
                        if artefact.checkIsMissingArchivePath() {
                            alert = .missingArchive(artefact)
                        } else {
                            presenter.revealArchiveInFinder(artefact)
                        }
                    } onResizeChanged: { translation in
                        resizeOffsets[artefact.id] = translation
                    } onResizeEnded: { translation in
                        
                        let deltaWidth = Int(
                            (translation.width / cellSize)
                                .rounded()
                        )
                        let deltaHeight = Int(
                            (translation.height / cellSize)
                                .rounded()
                        )
                        resizeArtefact(
                            artefact,
                            width: artefact.width + deltaWidth,
                            height: artefact.height + deltaHeight
                        )
                        resizeOffsets[artefact.id] = .zero
                    }
                    .frame(
                        width: displayedWidth,
                        height: displayedHeight
                    )
                    .position(
                        x:
                            CGFloat(artefact.column)
                            * cellSize
                            + displayedWidth / 2
                            + (dragOffsets[artefact.id]?.width ?? 0),

                        y:
                            CGFloat(artefact.row)
                            * cellSize
                            + displayedHeight / 2
                            + (dragOffsets[artefact.id]?.height ?? 0)
                    )
                    .animation(
                        .spring(),
                        value: resizeOffset
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffsets[artefact.id] =
                                    value.translation
                            }
                            .onEnded { value in

                                let deltaColumn = Int(
                                    (
                                        value.translation.width
                                        / cellSize
                                    ).rounded()
                                )

                                let deltaRow = Int(
                                    (
                                        value.translation.height
                                        / cellSize
                                    ).rounded()
                                )

                                moveArtefact(
                                    artefact,
                                    to: artefact.row + deltaRow,
                                    column: artefact.column + deltaColumn
                                )

                                dragOffsets[artefact.id] = .zero
                            }
                    )
                }
            }
            .padding()
        }
        .navigationTitle(workspace.name)
    }

    private func moveArtefact(
        _ artefact: Artefact,
        to row: Int,
        column: Int
    ) {

        artefact.row = row
        artefact.column = column

        try? modelContext.save()
    }

    private func resizeArtefact(
        _ artefact: Artefact,
        width: Int,
        height: Int
    ) {

        artefact.width = max(1, width)
        artefact.height = max(1, height)

        try? modelContext.save()
    }

    private func isValid(_ artefact: Artefact) -> Bool {

        if artefact.type == .archive &&
            artefact.checkIsMissingArchivePath() {

            alert = .missingArchive(artefact)
            return false
        }

        if artefact.type == .link &&
            !artefact.checkIsLinkValid() {

            alert = .invalidLink(artefact)
            return false
        }

        return true
    }

    private func handleUpdate(
        artefact: Artefact
    ) {
        switch artefact.type {
        case .archive:
            route = .updateArchive(artefact)
        case .link:
            route = .updateLink(artefact)
        case .text:
            break
        }
    }
}
