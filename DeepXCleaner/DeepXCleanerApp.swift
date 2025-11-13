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
    private let router = NavigationRouter()
    private let store = XcodeCleanerStore(.shared)
    private let preferences = CleanerPreferences.shared
    
    init() {
        if #available(macOS 13.0, *) { try? SMAppService.mainApp.register() }
    }
    
    var body: some Scene {
        MenuBarExtra {
            RootView()
                .environment(\.navigationRouter, router)
                .environment(\.xcodeCleanerStore, store)
                .environment(\.cleanerPreferences, preferences)
        } label: {
            VStack(spacing: 2) {
                Image("iconClear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
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
