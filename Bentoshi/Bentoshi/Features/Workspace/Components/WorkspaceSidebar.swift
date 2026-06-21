//
//  WorkspaceSidebar.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct WorkspaceSidebar: View {
    let workspaces: [Workspace]
    @Binding var selectedID: Workspace.ID?

    var body: some View {
        List(workspaces, selection: $selectedID) { workspace in
            Label(workspace.name, systemImage: "square.grid.2x2")
                .tag(workspace.id)
        }
        .navigationTitle("Workspaces")
    }
}
