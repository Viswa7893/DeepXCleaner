//
//  NSApplication+VersionInfo.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import AppKit

extension NSApplication {
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x.x"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "x"
    }
    
    static var fullVersionString: String {
        "\(appVersion).\(buildNumber)"
    }
}

