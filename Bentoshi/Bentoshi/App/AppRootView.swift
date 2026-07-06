//
//  ContentView.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

struct AppRootView: View {
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            HomeBuilder.build(context: context)
        }
        .frame(
            minWidth: 1100,
            minHeight: 800
        )
    }
}

#Preview {
    AppRootView()
}
