//
//  WorkspaceDetailContent.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct WorkspaceDetailContent: View {
    
    let workspace: Workspace
    let presenter: WorkspacePresenter
    @Binding var route: WorkspaceRoute?
    @Binding var alert: WorkspaceAlert?
    
    private let cellSize: CGFloat = 60
    
    //variaveis para o drag and drop
    @State private var dragOffset: CGSize = .zero
    
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
                        x: CGFloat(artefact.column) * cellSize + CGFloat(artefact.width) * cellSize / 2 + dragOffset.width,
                        y: CGFloat(artefact.row) * cellSize + CGFloat(artefact.height) * cellSize / 2 + dragOffset.height
                    )
                    .gesture(
                        DragGesture()
                            .onChanged {
                                dragOffset = $0.translation
                            }
                            .onEnded { _ in
                                dragOffset = .zero
                            }
                    )
                }
            }
            .padding()
        }
        .navigationTitle(workspace.name)
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
