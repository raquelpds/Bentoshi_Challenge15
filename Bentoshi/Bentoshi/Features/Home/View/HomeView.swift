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
    
    @AppStorage("sortOption")
    private var sortOptionRaw: String = SortOption.alphabet.rawValue
    
    var sortOption: SortOption {
        get { SortOption(rawValue: sortOptionRaw) ?? .lastModified }
        set { sortOptionRaw = newValue.rawValue }
    }
    
    var body: some View {
        ZStack {
            WorkspacesGrid(presenter: presenter, sortOption: sortOption)
                .opacity(isSearchActive ? 0 : 1)
                .allowsHitTesting(!isSearchActive)
            
            GlobalSearchContent(presenter: presenter, sortOption: sortOption)
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
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button{
                        sortOptionRaw = SortOption.alphabet.rawValue
                    } label: {
                        HStack(spacing: 4) {
                            if sortOption == .alphabet {
                                Image(systemName: "checkmark")
                            }
                            Text("A a Z")
                        }
                    }
                    
                    Button {
                        sortOptionRaw = SortOption.lastModified.rawValue
                    } label: {
                        HStack(spacing: 4) {
                            if sortOption == .lastModified {
                                Image(systemName: "checkmark")
                            }
                            Text("Modificado por último")
                        }
                    }
                    
                    Button{
                        sortOptionRaw = SortOption.lastCreated.rawValue
                    } label: {
                        HStack(spacing: 4) {
                            if sortOption == .lastCreated {
                                Image(systemName: "checkmark")
                            }
                            Text("Criado por último")
                        }
                    }
                } label: {
                    Image(systemName: "square.grid.3x1.below.line.grid.1x2")
                }
                .menuIndicator(.hidden)
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
