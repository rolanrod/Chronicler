//
//  ChroniclerApp.swift
//  Chronicler
//
//  Created by Rolando on 9/29/25.
//

import SwiftUI

@main
struct ChroniclerApp: App {
    @StateObject private var store = JournalStore()
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(store)
        }
    }
}
