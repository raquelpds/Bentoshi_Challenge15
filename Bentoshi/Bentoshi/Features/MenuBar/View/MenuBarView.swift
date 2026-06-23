//
//  MenuBarView.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI
import AppKit
import SwiftData

struct MenuBarView: View {
    @State var presenter: MenuBarPresenter?
    @Query(sort: \Workspace.updatedAt, order: .reverse) var workspaces: [Workspace]
    
    @State private var selectedWorkspace: Workspace? = nil
    
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            if let presenter = presenter {
                HStack {
                    Picker("", selection: $selectedWorkspace) {
                        ForEach(workspaces) { workspace in
                            Text(workspace.name)
                                .tag(workspace as Workspace?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Spacer()

                    HStack(spacing: 8) {
                        Circle()
                            .fill(selectedTab == 0 ? .primary : Color.gray.opacity(0.4))
                            .frame(width: 12, height: 12)
                            .onTapGesture {
                                selectedTab = 0
                            }

                        Circle()
                            .fill(selectedTab == 1 ? .primary : Color.gray.opacity(0.4))
                            .frame(width: 12, height: 12)
                            .onTapGesture {
                                selectedTab = 1
                            }
                    }
                }
                .padding(.trailing)
                
                if let workspace = selectedWorkspace {
                    if selectedTab == 0 {
                        AddFileView(presenter: presenter, workspace: workspace)
                    } else {
                        AddLinkView(presenter: presenter, workspace: workspace)
                    }
                }
                
            }
        }
        .onAppear{
            if presenter == nil {
                presenter = MenuBarBuilder.build(context: context)
            }
            if selectedWorkspace == nil {
                selectedWorkspace = workspaces.first
            }
        }
        .padding()
    }
}

enum DataType {
    case file
    case link
}

