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
    @Query(sort: \Workspace.updatedAt, order: .reverse) var workspaces: [Workspace]

    @State var presenter: MenuBarPresenter?
    @State var selectedWorkspace: Workspace? = nil
    
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context
    
    @State private var selectedTab: DataType = .link
    
    @State private var newReceivedLink = ""
    @State private var newLinkName = ""
    
    @State private var newFileUrl: URL?
    @State private var newFileName = ""
    
    var canSaveLink: Bool {
        let trimmedLink = newReceivedLink.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = newLinkName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedLink.isEmpty && !trimmedName.isEmpty
    }
    
    var canSaveFile: Bool {
        let trimmedName = newFileName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && newFileUrl != nil
    }
    
    var body: some View {
        VStack {
            if let presenter = presenter {
                HStack(alignment: .center) {
                    Picker("", selection: $selectedTab) {
                        ForEach(DataType.allCases) { type in
                            Text(type.name)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.palette)
                }
                .padding(.vertical, -20)
                
                if let workspace = selectedWorkspace {
                    if selectedTab == .link {
                        AddLinkView(
                            presenter: presenter,
                            workspaces: workspaces,
                            selectedWorkspace: $selectedWorkspace,
                            newReceivedLink: $newReceivedLink,
                            newLinkName: $newLinkName
                        )
                    } else {
                        AddFileView(
                            presenter: presenter,
                            workspaces: workspaces,
                            selectedWorkspace: $selectedWorkspace,
                            newFileUrl: $newFileUrl,
                            newFileName: $newFileName
                        )
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button("Limpar") {
                            switch selectedTab {
                            case .link:
                                newReceivedLink = ""
                                newLinkName = ""
                            case .file:
                                newFileName = ""
                                newFileUrl = nil
                            }
                        }
                        
                        Button("Salvar") {
                            Task {
                                switch selectedTab {
                                case .link:
                                    await presenter.addArtefact(
                                        to: workspace,
                                        payload: .link(
                                            url: newReceivedLink,
                                            name: newLinkName,
                                            keywords: []
                                        )
                                    )

                                    newReceivedLink = ""
                                    newLinkName = ""

                                case .file:
                                    guard let fileUrl = newFileUrl else { return }
                                    
                                    await presenter.addArtefact(
                                        to: workspace,
                                        payload: .archive(
                                            url: fileUrl,
                                            name: newFileName,
                                            keywords: []
                                        )
                                    )
                                    
                                    newFileUrl = nil
                                    newFileName = ""
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedTab == .link ? !canSaveLink : !canSaveFile)

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

enum DataType: String, CaseIterable, Identifiable {
    case link = "link"
    case file = "file"

    var id: Self { self }

    var name: String {
        switch self {
        case .link:
            return "Link"
        case .file:
            return "Arquivo"
        }
    }
}

