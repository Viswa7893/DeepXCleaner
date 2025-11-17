//
//  LoginItemManager.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import Foundation
import ServiceManagement
import os.log

final class LoginItemManager {
    
    static let shared = LoginItemManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner", category: "LoginItem")
    
    private init() {}
    
    /// Check if app is currently registered as a login item
    var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                return CleanerPreferences.shared.launchAtLogin.value
            }
        }
        set {
            setEnabled(newValue)
        }
    }
    
    /// Enable or disable launch at login
    private func setEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    // KEY FIX: Unregister first if already enabled to avoid conflicts
                    if SMAppService.mainApp.status == .enabled {
                        try? SMAppService.mainApp.unregister()
                    }
                    
                    try SMAppService.mainApp.register()
                    logger.info("✅ Successfully enabled launch at login")
                } else {
                    try SMAppService.mainApp.unregister()
                    logger.info("✅ Successfully disabled launch at login")
                }
            } catch {
                logger.error("❌ Failed to \(enabled ? "enable" : "disable") launch at login: \(error.localizedDescription)")
            }
        } else {
            // For macOS 12 and earlier - using deprecated API
            let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner"
            let success = SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled)
            
            if success {
                logger.info("✅ \(enabled ? "Enabled" : "Disabled") launch at login (macOS 12)")
            } else {
                logger.error("❌ Failed to \(enabled ? "enable" : "disable") launch at login (macOS 12)")
            }
        }
    }
    
    /// Register the app as a login item
    func register() {
        isEnabled = true
    }
    
    /// Unregister the app from login items
    func unregister() {
        isEnabled = false
    }
}
