//
//  DeepXCleanerApp.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import SwiftUI
import ServiceManagement

@main
struct DeepXCleanerApp: App {
    // MARK: - State Objects
    @State private var router = NavigationRouter()
    @State private var store = XcodeCleanerStore(.shared)
    @State private var preferences = CleanerPreferences.shared
    @State private var loginItemManager = LoginItemManager.shared
    
    init() {
        // Initialize auto-launch on first run
        setupAutoLaunch()
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
    
    // MARK: - Setup Auto Launch
    private func setupAutoLaunch() {
        // Check if this is first launch or if user wants auto-launch
        if preferences.launchAtLogin.value {
            // Sync the preference with actual system state
            if !loginItemManager.isEnabled {
                loginItemManager.register()
                print("✅ Auto-launch registered on app initialization")
            }
        } else {
            // If preference is false but it's enabled in system, remove it
            if loginItemManager.isEnabled {
                loginItemManager.unregister()
                print("❌ Auto-launch unregistered as per user preference")
            }
        }
    }
}
