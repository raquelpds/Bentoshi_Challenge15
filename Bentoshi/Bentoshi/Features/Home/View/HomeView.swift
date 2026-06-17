//
//  ContentView.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI

struct HomeView: View {
    
    @State var presenter: HomePresenter
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
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
