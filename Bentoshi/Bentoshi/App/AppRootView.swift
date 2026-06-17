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
        HomeBuilder.build(context: context)
    }
}

#Preview {
    AppRootView()
}
