//
//  DeepXCleanerApp.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import SwiftUI
import ServiceManagement
//import LaunchAtLogin

@main
struct DeepXCleanerApp: App {
    // MARK: - State Objects
    @State private var router = NavigationRouter()
    @State private var store = XcodeCleanerStore(.shared)
    @State private var preferences = CleanerPreferences.shared
    @State private var loginItemManager = LoginItemManager.shared
    
    init() {
        if preferences.launchAtLogin.value {
            loginItemManager.register()
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            RootView()
                .environment(\.navigationRouter, router)
                .environment(\.xcodeCleanerStore, store)
                .environment(\.cleanerPreferences, preferences)
        } label: {
            HStack(spacing: 5) {
                Image("iconClear")
                
                if preferences.showFreeSpaceInMenuBar.value {
                    Text(store.freedSpace.formattedBytes())
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
        }
        .menuBarExtraStyle(.window)
    }
}
