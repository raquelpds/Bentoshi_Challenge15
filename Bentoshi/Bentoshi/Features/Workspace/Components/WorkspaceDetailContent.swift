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
    private let rows = 20
    private let columns = 20

    @State private var dragOffsets: [UUID: CGSize] = [:]
    @State private var resizeOffsets: [UUID: CGSize] = [:]

    var body: some View {

        ScrollView([.horizontal, .vertical]) {

            ZStack(alignment: .topLeading) {

                GridBackground(
                    rows: 20,
                    columns: 20
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
                        if artefact.type == .text {
                            route = .updateText(artefact)
                        }
                        else if (isValid(artefact)){
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
                            CGFloat(artefact.gridColumn)
                            * cellSize
                            + displayedWidth / 2
                            + (dragOffsets[artefact.id]?.width ?? 0),

                        y:
                            CGFloat(artefact.gridRow)
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
                                    to: artefact.gridRow + deltaRow,
                                    column: artefact.gridColumn + deltaColumn
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
        //isso daqui serve para verificar se o artefato será movido para fora da área do grid. Eu declarei uma variável
        //chamada row and column e nelas eu coloquei o tamanho específico da nossa grid. Caso o artefato esteja numa row e column maior ou menor que a da variável, ele retorna o artefato para sua posição inicial.
        guard isPlacementValid(
            artefact: artefact,
            row: row,
            column: column,
            width: artefact.width,
            height: artefact.height

        ) else {
            return
        }
        //se estiver dentro do grid, atualiza a row e a column do artefato.
        artefact.gridRow = row
        artefact.gridColumn = column
        
        //salva row e column no banco de dados.
        try? modelContext.save()
    }
    
    private func isPlacementValid(
        artefact: Artefact,
        row: Int,
        column: Int,
        width: Int,
        height: Int
    ) -> Bool {

        // Verifica limites da grid
        if row < 0 ||
            column < 0 ||
            row + height > rows ||
            column + width > columns {

            return false
        }

        // Verifica colisão com outros artefatos
        for other in workspace.artefacts {

            // Ignora o próprio artefato
            if other.id == artefact.id {
                continue
            }

            let overlap = !(
                column + width <= other.gridColumn ||
                column >= other.gridColumn + other.width ||
                row + height <= other.gridRow ||
                row >= other.gridRow + other.height
            )

            if overlap {
                return false
            }
        }

        return true
    }

    private func resizeArtefact(
        _ artefact: Artefact,
        width: Int,
        height: Int
    ) {
        
        //a função MAX (nativa do IOS) recebe dois valores e devolve o maior deles.
        //Isso daqui serve para evitar que o valor fique menor que o InitialWidth e InitialHeight, definido lá no ArtefactType.
        //Ou seja, não é possível diminuir o card do link para menor que 3 colunas.
        
        let newWidth = max(artefact.type.initialWidth, width)

        let newHeight = max(artefact.type.initialHeight,height)
        
        guard isPlacementValid(
            artefact: artefact,
            row: artefact.gridRow,
            column: artefact.gridColumn,
            width: newWidth,
            height: newHeight

        ) else {
            return
        }

        artefact.width = newWidth
        artefact.height = newHeight

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
            route = .updateText(artefact)
        }
    }
}
