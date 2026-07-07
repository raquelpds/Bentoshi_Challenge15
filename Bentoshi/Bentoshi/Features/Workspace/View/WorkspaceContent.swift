//
//  WorkspaceContent.swift
//  Bentoshi
//
//  Created by Raquel Souza on 30/06/26.
//

import SwiftUI

private struct GridPosition {
    let row: Int
    let column: Int
}

struct WorkspaceContent: View {
    
    @Environment(\.colorScheme) private var colorScheme

    let workspace: Workspace
    let presenter: WorkspacePresenter

    @Binding var route: WorkspaceSheetRoute?
    @Binding var detailRoute: WorkspaceDetailRoute?
    @Binding var alert: WorkspaceAlert?

    private let cellSize: CGFloat = 60
    private let columns: Int = 25
//    private let horizontalPadding: CGFloat = 16
//    private let verticalPadding: CGFloat = 24

    @State private var rows: Int = 30
    
    private let artefactGap: CGFloat = 16
    
    //para não criar infinitamente, criar um limite para linhas
    private var minimumRowsNeededForArtefacts: Int {
        let maxArtefactRow = workspace.artefacts.map { artefact in
            artefact.gridRow + artefact.height
        }
        .max() ?? 0

        return maxArtefactRow + 10
    }

    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var resizeOffsets: [UUID: CGSize] = [:]

    @State private var draggingArtefactID: UUID?
    @State private var selectedArtefactID: UUID?
    
    @State private var temporaryGridPositions: [UUID: GridPosition] = [:]
    @State private var pendingResizeSizes: [UUID: CGSize] = [:]
    
    private let gridLeftPadding: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            
            let gridWidth = CGFloat(columns) * cellSize
            let effectiveRows = max(rows, minimumRowsNeededForArtefacts)
            let gridHeight = CGFloat(effectiveRows) * cellSize
            
            let gridContainerWidth = gridWidth + gridLeftPadding

            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .center) {

                    GridBackground(
                        rows: effectiveRows,
                        columns: columns,
                        cellSize: cellSize
                    )
                    .frame(
                        width: gridWidth,
                        height: gridHeight,
                        alignment: .topLeading
                    )
                    
                    ForEach(workspace.artefacts) { artefact in
                        positionedArtefactCard(artefact)
                    }

                    loadMoreTrigger(
                        effectiveRows: effectiveRows,
                        gridHeight: gridHeight
                    )
                }
                .padding(.leading, gridLeftPadding)
                .frame(
                    width: gridContainerWidth,
                    height: gridHeight,
                    alignment: .topLeading
                )
            }
        }
    }
}

//funções de cálculo de tela
//raquel
extension WorkspaceContent {
    
    private func gridRow(for artefact: Artefact) -> Int {
        temporaryGridPositions[artefact.id]?.row ?? artefact.gridRow
    }

    private func gridColumn(for artefact: Artefact) -> Int {
        temporaryGridPositions[artefact.id]?.column ?? artefact.gridColumn
    }
    
    private func visualWidth(from gridWidth: CGFloat) -> CGFloat {
        max(cellSize - artefactGap, gridWidth - artefactGap)
    }

    private func visualHeight(from gridHeight: CGFloat) -> CGFloat {
        max(cellSize - artefactGap, gridHeight - artefactGap)
    }

    private func resizeOffset(for artefact: Artefact) -> CGSize {
        resizeOffsets[artefact.id] ?? .zero
    }

    private func dragOffset(for artefact: Artefact) -> CGSize {
        dragOffsets[artefact.id] ?? .zero
    }

    private func displayedWidth(for artefact: Artefact) -> CGFloat {
        if let pendingSize = pendingResizeSizes[artefact.id] {
            return CGFloat(pendingSize.width) * cellSize
        }

        let offset = resizeOffset(for: artefact)

        let baseWidth = CGFloat(artefact.width) * cellSize
        let resizedWidth = baseWidth + offset.width

        let minimumWidth = CGFloat(artefact.type.initialWidth) * cellSize

        return max(minimumWidth, resizedWidth)
    }

    private func displayedHeight(for artefact: Artefact) -> CGFloat {
        if let pendingSize = pendingResizeSizes[artefact.id] {
            return CGFloat(pendingSize.height) * cellSize
        }

        let offset = resizeOffset(for: artefact)

        let baseHeight = CGFloat(artefact.height) * cellSize
        let resizedHeight = baseHeight + offset.height

        let minimumHeight = CGFloat(artefact.type.initialHeight) * cellSize

        return max(minimumHeight, resizedHeight)
    }

    private func positionX(
        for artefact: Artefact,
        displayedWidth: CGFloat
    ) -> CGFloat {
        CGFloat(gridColumn(for: artefact)) * cellSize
        + displayedWidth / 2
        + dragOffset(for: artefact).width
    }

    private func positionY(
        for artefact: Artefact,
        displayedHeight: CGFloat
    ) -> CGFloat {
        CGFloat(gridRow(for: artefact)) * cellSize
        + displayedHeight / 2
        + dragOffset(for: artefact).height
    }

    @ViewBuilder
    private func loadMoreTrigger(
        effectiveRows: Int,
        gridHeight: CGFloat
    ) -> some View {
        Color.clear
            .frame(width: 1, height: 1)
            .position(
                x: 1,
                y: max(0, gridHeight - 300)
            )
            .onAppear {
                if rows <= effectiveRows {
                    rows = effectiveRows + 20
                }
            }
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
            workspaceColor: workspace.coverColor,
            artefactType: artefact.type,
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
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    resizeOffsets[artefact.id] = translation
                }
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
            width: visualWidth(from: width),
            height: visualHeight(from: height)
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
        .transaction { transaction in
            if draggingArtefactID == artefact.id {
                transaction.animation = nil
            }
        }
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
                
                withTransaction(Transaction(animation: nil)) {
                    dragOffsets[artefact.id] = value.translation
                }
            }
            .onEnded { value in
                let deltaColumn = Int(
                    (value.translation.width / cellSize).rounded()
                )
                
                let deltaRow = Int(
                    (value.translation.height / cellSize).rounded()
                )
                
                let newRow = max(
                    0,
                    artefact.gridRow + deltaRow
                )
                
                let newColumn = max(
                    0,
                    artefact.gridColumn + deltaColumn
                )
                
                withTransaction(Transaction(animation: nil)) {
                    temporaryGridPositions[artefact.id] = GridPosition(
                        row: newRow,
                        column: newColumn
                    )
                    
                    dragOffsets[artefact.id] = .zero
                    draggingArtefactID = nil
                }
                
                Task {
                    await handleMoveEnded(
                        artefact,
                        row: newRow,
                        column: newColumn
                    )
                    
                    await MainActor.run {
                        temporaryGridPositions[artefact.id] = nil
                    }
                }
            }
    }
    
    private func handleMoveEnded(
        _ artefact: Artefact,
        row: Int,
        column: Int
    ) async {
        await MainActor.run {
            rows = max(
                rows,
                row + artefact.height + 10
            )
        }
        
        await presenter.moveArtefact(
            artefact,
            in: workspace,
            to: row,
            column: column
        )
    }
    
    private func handleResizeEnded(
        _ artefact: Artefact,
        translation: CGSize
    ) {
        let baseWidth = CGFloat(artefact.width) * cellSize
        let baseHeight = CGFloat(artefact.height) * cellSize

        let finalVisualWidth = baseWidth + translation.width
        let finalVisualHeight = baseHeight + translation.height

        let newWidth = max(
            artefact.type.initialWidth,
            Int((finalVisualWidth / cellSize).rounded())
        )

        let newHeight = max(
            artefact.type.initialHeight,
            Int((finalVisualHeight / cellSize).rounded())
        )

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            pendingResizeSizes[artefact.id] = CGSize(
                width: CGFloat(newWidth),
                height: CGFloat(newHeight)
            )

            resizeOffsets[artefact.id] = .zero
        }

        Task {
            await presenter.resizeArtefact(
                artefact,
                in: workspace,
                width: newWidth,
                height: newHeight
            )

            await MainActor.run {
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    pendingResizeSizes[artefact.id] = nil
                }
            }
        }
    }
}
