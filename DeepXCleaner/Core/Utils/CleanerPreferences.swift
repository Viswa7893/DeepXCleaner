//
//  CleanerPreferences.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

@Observable
final class CleanerPreferences {
    
    static let shared = CleanerPreferences()
    
    // MARK: - Cleanup Toggles
    // Updated to use string keys instead of ShellExecutor.Command references
    var cleanArchives = PersistentValue("cleanArchives", defaultValue: true)
    var cleanCaches = PersistentValue("cleanCaches", defaultValue: true)
    var cleanDerivedData = PersistentValue("cleanDerivedData", defaultValue: true)
    var cleanDeviceSupport = PersistentValue("cleanDeviceSupport", defaultValue: false)
    var pruneOldSimulators = PersistentValue("pruneOldSimulators", defaultValue: false)
    var cleanSimulatorData = PersistentValue("cleanSimulatorData", defaultValue: false)
    var resetXcodeSettings = PersistentValue("resetXcodeSettings", defaultValue: false)
    
    // MARK: - UI Preference
    var showFreeSpaceInMenuBar = PersistentValue("display-free-up-space-in-menu-bar", defaultValue: true)
    var launchAtLogin = PersistentValue("launch-at-login", defaultValue: true)
}

extension EnvironmentValues {
    @Entry var cleanerPreferences = CleanerPreferences()
}
