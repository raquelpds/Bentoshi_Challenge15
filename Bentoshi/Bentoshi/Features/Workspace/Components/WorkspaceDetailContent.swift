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
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
                spacing: 16
            ) {
                ForEach(workspace.artefacts) { artefact in
                    ArtefactCard(
                        artefact: artefact,
                        pallete: workspace.coverColor
                    ) {
                        if (isValid(artefact)){
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
