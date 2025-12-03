//
//  NSApplication+VersionInfo.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import Foundation
import AppKit

extension Bundle {
    /// Returns the app version (CFBundleShortVersionString)
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// Returns the build number (CFBundleVersion)
    var appBuild: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// Returns formatted version string: "Version 1.0.2"
    var fullVersionString: String {
        "\(appVersion).\(appBuild)"
    }
    
    /// Returns simple version string: "Version 1.0"
    var simpleVersionString: String {
        "Version \(appVersion)"
    }
}

extension NSApplication {
    /// Legacy support - returns full version string
    static var fullVersionString: String {
        Bundle.main.fullVersionString
    }
    
    /// Returns just the version number (e.g., "1.0")
    static var appVersion: String {
        Bundle.main.appVersion
    }
    
    /// Returns just the build number (e.g., "2")
    static var appBuild: String {
        Bundle.main.appBuild
    }
}

