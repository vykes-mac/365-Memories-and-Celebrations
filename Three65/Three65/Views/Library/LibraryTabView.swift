//
//  LibraryTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Library tab - creative library of saved collages
struct LibraryTabView: View {
    var body: some View {
        NavigationStack {
            CreativeLibraryView()
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    LibraryTabView()
}
