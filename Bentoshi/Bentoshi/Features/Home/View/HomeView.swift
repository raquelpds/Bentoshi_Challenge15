//
//  ContentView.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI

struct HomeView: View {
    
    @State var presenter: HomePresenter
    @State private var showModal = false
    @State private var shouldReloadWorkspaces = false
    @Environment(\.modelContext) private var context
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    
                    Button {
                        showModal = true
                    } label: {
                        AddWorkspaceCard()
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(presenter.workspaces) { workspace in
                        NavigationLink {
                            WorkspaceBuilder.build(context: context, workspace: workspace, shouldReloadWorkspace: $shouldReloadWorkspaces)
                        } label: {
                            WorkspaceCard(workspace: workspace)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Workspaces")
        }
        .sheet(isPresented: $showModal) {
            CreateWorkspaceView { workspace, newName, newColor in
                Task {
                    await presenter.addWorkspace(workspace)
                }
            }
        }
        .task {
            await presenter.listWorkspaces()
        }
        .onChange(of: shouldReloadWorkspaces) { oldValue, newValue in
            if (shouldReloadWorkspaces) {
                Task {
                    await presenter.listWorkspaces()
                }
                shouldReloadWorkspaces = false
            }
        }
    }
}

#Preview {
    struct PreviewWithContextWrapper: View {
        @Environment(\.modelContext) private var context
        var body: some View {
            HomeBuilder.build(context: context)
        }
    }
    
    return PreviewWithContextWrapper()
}
