//
//  LoginItemManager.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

//
//  LoginItemManager.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import Foundation
import os.log

final class LoginItemManager {
    
    static let shared = LoginItemManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner", category: "LoginItem")
    
    private init() {}
    
    /// Check if app is currently registered as a login item
    var isEnabled: Bool {
        get {
            return launchAgentExists()
        }
        set {
            setEnabled(newValue)
        }
    }
    
    /// Enable or disable launch at login using LaunchAgent (works without sandbox)
    private func setEnabled(_ enabled: Bool) {
        let launchAgentPath = launchAgentPlistPath()
        let fileManager = FileManager.default
        
        if enabled {
            // Create LaunchAgents directory if it doesn't exist
            let launchAgentsDir = (launchAgentPath as NSString).deletingLastPathComponent
            if !fileManager.fileExists(atPath: launchAgentsDir) {
                try? fileManager.createDirectory(atPath: launchAgentsDir, withIntermediateDirectories: true)
            }
            
            // Create plist content
            let bundleID = Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner"
            let appPath = Bundle.main.bundlePath
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(bundleID)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(appPath)/Contents/MacOS/DeepXCleaner</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
            </dict>
            </plist>
            """
            
            do {
                try plistContent.write(toFile: launchAgentPath, atomically: true, encoding: .utf8)
                logger.info("Successfully enabled launch at login (LaunchAgent)")
            } catch {
                logger.error("Failed to create LaunchAgent: \(error.localizedDescription)")
            }
        } else {
            // Remove launch agent
            if fileManager.fileExists(atPath: launchAgentPath) {
                do {
                    try fileManager.removeItem(atPath: launchAgentPath)
                    logger.info("Successfully disabled launch at login")
                } catch {
                    logger.error("Failed to remove LaunchAgent: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func launchAgentPlistPath() -> String {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let bundleID = Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner"
        return "\(homeDir)/Library/LaunchAgents/\(bundleID).plist"
    }
    
    private func launchAgentExists() -> Bool {
        return FileManager.default.fileExists(atPath: launchAgentPlistPath())
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
