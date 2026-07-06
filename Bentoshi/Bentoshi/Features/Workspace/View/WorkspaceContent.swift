//
//  WorkspaceContent.swift
//  Bentoshi
//
//  Created by Raquel Souza on 30/06/26.
//

import SwiftUI

struct WorkspaceContent: View {
    
    @Environment(\.colorScheme) private var colorScheme

    let workspace: Workspace
    let presenter: WorkspacePresenter

    @Binding var route: WorkspaceSheetRoute?
    @Binding var detailRoute: WorkspaceDetailRoute?
    @Binding var alert: WorkspaceAlert?

    private let cellSize: CGFloat = 60
    private let rows = 20
    private let columns = 20

    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var resizeOffsets: [UUID: CGSize] = [:]

    @State private var draggingArtefactID: UUID?
    @State private var selectedArtefactID: UUID?

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                GridBackground(
                    rows: rows,
                    columns: columns
                )

                ForEach(workspace.artefacts) { artefact in
                    positionedArtefactCard(artefact)
                }
            }
            .frame(
                width: CGFloat(columns) * cellSize,
                height: CGFloat(rows) * cellSize,
                alignment: .topLeading
            )
            .padding()
        }
    }
}

//funções de cálculo de tela
//raquel
extension WorkspaceContent {

    private func resizeOffset(for artefact: Artefact) -> CGSize {
        resizeOffsets[artefact.id] ?? .zero
    }

    private func dragOffset(for artefact: Artefact) -> CGSize {
        dragOffsets[artefact.id] ?? .zero
    }

    private func displayedWidth(for artefact: Artefact) -> CGFloat {
        let offset = resizeOffset(for: artefact)

        let resizedWidth = artefact.width + Int(
            (offset.width / cellSize).rounded()
        )

        return CGFloat(max(1, resizedWidth)) * cellSize
    }

    private func displayedHeight(for artefact: Artefact) -> CGFloat {
        let offset = resizeOffset(for: artefact)

        let resizedHeight = artefact.height + Int(
            (offset.height / cellSize).rounded()
        )

        return CGFloat(max(1, resizedHeight)) * cellSize
    }

    private func positionX(
        for artefact: Artefact,
        displayedWidth: CGFloat
    ) -> CGFloat {
        CGFloat(artefact.gridColumn) * cellSize
        + displayedWidth / 2
        + dragOffset(for: artefact).width
    }

    private func positionY(
        for artefact: Artefact,
        displayedHeight: CGFloat
    ) -> CGFloat {
        CGFloat(artefact.gridRow) * cellSize
        + displayedHeight / 2
        + dragOffset(for: artefact).height
    }
}

//aqui monta o card, define tamanho, posição, gesto de arrastar e gesto de redimensionar.
//raquel
extension WorkspaceContent {

    @ViewBuilder
    private func positionedArtefactCard(
        _ artefact: Artefact
    ) -> some View {
        let width = displayedWidth(for: artefact)
        let height = displayedHeight(for: artefact)
        
        let backgroundColor = presenter.backgroundColor(
            for: artefact,
            palette: workspace.coverColor,
            scheme: colorScheme
        )

        ArtefactCard(
            name: artefact.name,
            backgroundColor: presenter.backgroundColor(
                for: artefact,
                palette: workspace.coverColor,
                scheme: colorScheme
            ),
            showsRevealInFinder: presenter.shouldShowRevealInFinder(
                for: artefact
            ),
            preview: ArtefactPreview(
                type: artefact.type,
                name: artefact.name,
                content: artefact.content,
                archivePreviewImage: presenter.archivePreviewImage(for: artefact),
                backgroundColor: backgroundColor
            ),
            onOpen: {
                handleOpen(artefact)
            },
            onUpdate: {
                handleUpdate(artefact)
            },
            onDelete: {
                alert = .deleteArtefact(artefact)
            },
            onRevealInFinder: {
                handleRevealInFinder(artefact)
            },
            onResizeChanged: { translation in
                resizeOffsets[artefact.id] = translation
            },
            onResizeEnded: { translation in
                handleResizeEnded(
                    artefact,
                    translation: translation)
            },
            showsHoverOverlay: presenter.shouldShowHoverOverlay(
                    for: artefact
            )
        )
        .frame(
            width: width,
            height: height
        )
        .position(
            x: positionX(
                for: artefact,
                displayedWidth: width
            ),
            y: positionY(
                for: artefact,
                displayedHeight: height
            )
        )
        .zIndex(draggingArtefactID == artefact.id ? 1 : 0)
        .animation(
            .spring(),
            value: resizeOffset(for: artefact)
        )
        .gesture(
            dragGesture(for: artefact)
        )
        .onTapGesture {
            selectedArtefactID = artefact.id
        }
    }
}


//handlers.
//raquel
extension WorkspaceContent {

    private func handleOpen(_ artefact: Artefact) {
        if presenter.shouldEditInsteadOfOpen(artefact) {
            detailRoute = .updateText(artefact)
            return
        }

        if let neededAlert = presenter.alertForOpeningIfNeeded(artefact) {
            alert = neededAlert
            return
        }

        presenter.open(artefact)
    }
    
    private func handleUpdate(_ artefact: Artefact) {
        if artefact.type == .text {
            detailRoute = .updateText(artefact)
            return
        }

        route = presenter.routeForUpdating(artefact)
    }

    private func handleRevealInFinder(_ artefact: Artefact) {
        if let neededAlert = presenter.alertForRevealInFinderIfNeeded(artefact) {
            alert = neededAlert
            return
        }

        presenter.revealArchiveInFinder(artefact)
    }
}

//Aqui fica o comportamento visual de arrastar/redimensionar.
//raquel
extension WorkspaceContent {

    private func dragGesture(
        for artefact: Artefact
    ) -> some Gesture {
        DragGesture()
            .onChanged { value in
                draggingArtefactID = artefact.id
                dragOffsets[artefact.id] = value.translation
            }
            .onEnded { value in
                let deltaColumn = Int(
                    (value.translation.width / cellSize).rounded()
                )

                let deltaRow = Int(
                    (value.translation.height / cellSize).rounded()
                )

                handleMoveEnded(
                    artefact,
                    deltaRow: deltaRow,
                    deltaColumn: deltaColumn
                )

                draggingArtefactID = nil
                dragOffsets[artefact.id] = .zero
            }
    }

    private func handleMoveEnded(
        _ artefact: Artefact,
        deltaRow: Int,
        deltaColumn: Int
    ) {
        let newRow = artefact.gridRow + deltaRow
        let newColumn = artefact.gridColumn + deltaColumn

        Task {
            await presenter.moveArtefact(
                artefact,
                in: workspace,
                to: newRow,
                column: newColumn
            )
        }
    }

    private func handleResizeEnded(
        _ artefact: Artefact,
        translation: CGSize
    ) {
        let deltaWidth = Int(
            (translation.width / cellSize).rounded()
        )

        let deltaHeight = Int(
            (translation.height / cellSize).rounded()
        )

        let newWidth = artefact.width + deltaWidth
        let newHeight = artefact.height + deltaHeight

        Task {
            await presenter.resizeArtefact(
                artefact,
                in: workspace,
                width: newWidth,
                height: newHeight
            )
        }

        resizeOffsets[artefact.id] = .zero
    }
}
