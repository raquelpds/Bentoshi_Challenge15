//
//  HomeEmptyState.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

//
//  HomeEmptyState.swift
//  Bentoshi
//

import SwiftUI

struct HomeEmptyState: View {

    var body: some View {
        ZStack {
            
            Text("""
            Clique no "+" para adicionar
            um novo Bentoshi
            """)
            .font(.system(size: 26))
            .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack {
                Spacer()

                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 700)
            }
        }
    }
}
