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
    var cleanArchives = PersistentValue(ShellExecutor.Command.cleanArchives.rawValue, defaultValue: true)
    var cleanCaches = PersistentValue(ShellExecutor.Command.cleanCaches.rawValue, defaultValue: true)
    var cleanDerivedData = PersistentValue(ShellExecutor.Command.cleanDerivedData.rawValue, defaultValue: true)
    var cleanDeviceSupport = PersistentValue(ShellExecutor.Command.cleanDeviceSupport.rawValue, defaultValue: false)
    var pruneOldSimulators = PersistentValue(ShellExecutor.Command.pruneOldSimulators.rawValue, defaultValue: false)
    var cleanSimulatorData = PersistentValue(ShellExecutor.Command.cleanSimulatorData.rawValue, defaultValue: false)
    var resetXcodeSettings = PersistentValue(ShellExecutor.Command.resetXcodeSettings.rawValue, defaultValue: false)
    
    // MARK: - UI Preference
    var showFreeSpaceInMenuBar = PersistentValue("display-free-up-space-in-menu-bar", defaultValue: true)
    var launchAtLogin = PersistentValue("launch-at-login", defaultValue: true)
}

extension EnvironmentValues {
    @Entry var cleanerPreferences = CleanerPreferences()
}
