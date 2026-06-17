//
//  WorkspacePresenter.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI

@Observable
final class WorkspacePresenter {
    private let interactor: WorkspaceInteractor
    
    init(interactor: WorkspaceInteractor) {
        self.interactor = interactor
    }
}
