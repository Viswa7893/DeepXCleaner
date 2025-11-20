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
            return launchAgentExists() && isLaunchAgentValid()
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
                do {
                    try fileManager.createDirectory(atPath: launchAgentsDir, withIntermediateDirectories: true)
                    logger.info("Created LaunchAgents directory")
                } catch {
                    logger.error("Failed to create LaunchAgents directory: \(error.localizedDescription)")
                    return
                }
            }
            
            // Get the actual executable path (more reliable than bundlePath)
            guard let executablePath = Bundle.main.executablePath else {
                logger.error("Could not determine executable path")
                return
            }
            
            let bundleID = Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner"
            
            // Create plist with proper structure and debugging output
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(bundleID)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(executablePath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
                <key>StandardOutPath</key>
                <string>/tmp/deepxcleaner.out.log</string>
                <key>StandardErrorPath</key>
                <string>/tmp/deepxcleaner.err.log</string>
            </dict>
            </plist>
            """
            
            do {
                try plistContent.write(toFile: launchAgentPath, atomically: true, encoding: .utf8)
                logger.info("Successfully created LaunchAgent at: \(launchAgentPath)")
                logger.info("Executable path: \(executablePath)")
                
                // Load the LaunchAgent immediately (don't wait for next login)
                loadLaunchAgent()
            } catch {
                logger.error("Failed to write LaunchAgent plist: \(error.localizedDescription)")
            }
        } else {
            // Unload first, then remove
            unloadLaunchAgent()
            
            if fileManager.fileExists(atPath: launchAgentPath) {
                do {
                    try fileManager.removeItem(atPath: launchAgentPath)
                    logger.info("Successfully removed LaunchAgent")
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
    
    private func isLaunchAgentValid() -> Bool {
        let path = launchAgentPlistPath()
        guard FileManager.default.fileExists(atPath: path),
              let data = FileManager.default.contents(atPath: path),
              let plistDict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let programArgs = plistDict["ProgramArguments"] as? [String],
              let executablePath = programArgs.first else {
            return false
        }
        
        // Verify the executable actually exists
        return FileManager.default.fileExists(atPath: executablePath)
    }
    
    private func loadLaunchAgent() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["load", launchAgentPlistPath()]
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                logger.info("Successfully loaded LaunchAgent")
            } else {
                logger.warning("LaunchAgent load returned status: \(process.terminationStatus)")
            }
        } catch {
            logger.error("Failed to load LaunchAgent: \(error.localizedDescription)")
        }
    }
    
    private func unloadLaunchAgent() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["unload", launchAgentPlistPath()]
        
        do {
            try process.run()
            process.waitUntilExit()
            logger.info("Unloaded LaunchAgent")
        } catch {
            logger.error("Failed to unload LaunchAgent: \(error.localizedDescription)")
        }
    }
    
    /// Register the app as a login item
    func register() {
        // Only register if not already enabled
        if !isEnabled {
            isEnabled = true
        }
    }
    
    /// Unregister the app from login items
    func unregister() {
        isEnabled = false
    }
    
    /// Debug: Print LaunchAgent status
    func debugStatus() {
        let path = launchAgentPlistPath()
        logger.info("LaunchAgent path: \(path)")
        logger.info("Exists: \(self.launchAgentExists())")
        logger.info("Valid: \(self.isLaunchAgentValid())")
        
        if let execPath = Bundle.main.executablePath {
            logger.info("Current executable: \(execPath)")
            logger.info("Executable exists: \(FileManager.default.fileExists(atPath: execPath))")
        }
        
        // Check if it's loaded in launchctl
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if let data = try? pipe.fileHandleForReading.readToEnd(),
               let output = String(data: data, encoding: .utf8) {
                let bundleID = Bundle.main.bundleIdentifier ?? "com.viswa.DeepXCleaner"
                let isLoaded = output.contains(bundleID)
                logger.info("Loaded in launchctl: \(isLoaded)")
            }
        } catch {
            logger.error("Failed to check launchctl: \(error.localizedDescription)")
        }
    }
}
