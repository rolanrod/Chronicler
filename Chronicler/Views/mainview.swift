//
//  mainview.swift
//  Chronicler
//
//  Created by Rolando on 9/30/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Chronicler").font(.largeTitle).padding()
            Text("Journal app is running!").foregroundColor(.secondary)
        }.frame(minWidth: 800, minHeight: 600)

    }
}

#Preview {
    MainView()
}
