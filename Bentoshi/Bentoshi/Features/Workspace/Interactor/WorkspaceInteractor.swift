//
//  HomeInteractor.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

final class WorkspaceInteractor {
    
    private let workspaceService: WorkspaceServiceProtocol
    private let artefactService: ArtefactServiceProtocol
    
    init(workspaceService: WorkspaceServiceProtocol, artefactService: ArtefactServiceProtocol) {
        self.workspaceService = workspaceService
        self.artefactService = artefactService
    }
}
