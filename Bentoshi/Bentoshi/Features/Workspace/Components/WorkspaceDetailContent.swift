//
//  WorkspaceDetailContent.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI
import SwiftData

struct WorkspaceDetailContent: View {
    
    //Variaveis adicionadas por Raquel
    @Environment(\.modelContext)
    private var modelContext
    
    let workspace: Workspace
    let presenter: WorkspacePresenter
    @Binding var route: WorkspaceRoute?
    @Binding var alert: WorkspaceAlert?
    
    private let cellSize: CGFloat = 60
    
    @State private var dragOffsets: [UUID: CGSize] = [:]

    
    var body: some View {

        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {

                GridBackground(rows: 25, columns: 25)

                ForEach(workspace.artefacts) { artefact in

                    ArtefactCard(
                        artefact: artefact,
                        pallete: workspace.coverColor
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
                    }
                    .frame(width: CGFloat(artefact.width) * cellSize, height: CGFloat(artefact.height) * cellSize)
                    .position(
                        x: CGFloat(artefact.column) * cellSize
                            + CGFloat(artefact.width) * cellSize / 2
                            + (dragOffsets[artefact.id]?.width ?? 0),

                        y: CGFloat(artefact.row) * cellSize
                            + CGFloat(artefact.height) * cellSize / 2
                            + (dragOffsets[artefact.id]?.height ?? 0)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged {
                                dragOffsets[artefact.id] = $0.translation
                            }
                            .onEnded { value in

                                let deltaColumn = Int(
                                    (value.translation.width / cellSize)
                                        .rounded()
                                )

                                let deltaRow = Int(
                                    (value.translation.height / cellSize)
                                        .rounded()
                                )

                                moveArtefact(
                                    artefact,
                                    to: artefact.row + deltaRow,
                                    column: artefact.column + deltaColumn
                                )

                                dragOffsets.removeValue(forKey: artefact.id)
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
        
        print("ANTES")
        print(artefact.row)
        print(artefact.column)

        try? modelContext.save()
        
        print("DEPOIS")
        print(artefact.row)
        print(artefact.column)
    }
    
    private func isValid(_ artefact: Artefact) -> Bool {
        if artefact.type == .archive && artefact.checkIsMissingArchivePath() {
            alert = .missingArchive(artefact)
            return false
        }
        
        if artefact.type == .link && !artefact.checkIsLinkValid() {
            alert = .invalidLink(artefact)
            return false
        }
        
        return true
    }
    
    private func handleUpdate(artefact: Artefact){
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
