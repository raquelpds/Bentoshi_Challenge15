//
//  WorkspacePresenter.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI

@Observable
final class HomePresenter {
    private let interactor: HomeInteractor
    
    init(interactor: HomeInteractor) {
        self.interactor = interactor
    }
}
