//
//  ContentView.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var workspaces: [Workspace]
    
    @State var presenter: HomePresenter
    
    var body: some View {
        ZStack {
            WorkspacesGrid(presenter: presenter)
                .opacity(isSearchActive ? 0 : 1)
                .allowsHitTesting(!isSearchActive)
            
            GlobalSearchContent(presenter: presenter)
                .opacity(isSearchActive ? 1 : 0)
                .allowsHitTesting(isSearchActive)
        }
        .navigationTitle("Workspaces")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SearchToolbarItem(
                    searchText: $presenter.searchText,
                    isExpanded: $presenter.isSearchBarExpanded
                )
            }
        }
        .onAppear {
            if !presenter.searchText.isEmpty {
                presenter.searchText = ""
            }
        }
        .onChange(of: presenter.searchText) { _, _ in
            presenter.onSearchTextChanged()
        }
    }
    
    private var isSearchActive: Bool {
        !presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
