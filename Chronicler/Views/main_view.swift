//
//  mainview.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var store: JournalStore
    
    var body: some View {
        VStack {
            Text("Chronicler").font(.largeTitle).padding()
            Text("You have \(store.entries.count) journal entries!").foregroundColor(.secondary)
            
            List(store.entries) { entry in
                VStack(alignment: .leading) {
                    Text(entry.title).font(.headline)
                    Text(entry.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }.frame(minWidth:800, minHeight:800)
    }
}

#Preview {
    MainView()
        .environmentObject(JournalStore())
}
