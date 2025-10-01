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
        NavigationStack {
            CalendarView()
                .environmentObject(store)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(JournalStore())
}
