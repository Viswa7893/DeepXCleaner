//
//  ShellExecutor.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import SwiftUI
import Foundation

final class ShellExecutor {
    
    @discardableResult
    func execute(_ command: Command) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            guard let scriptPath = command.scriptPath else {
                continuation.resume(throwing: ShellError.scriptNotFound(command.rawValue))
                return
            }
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [scriptPath]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                
                var outputString: String?
                
                if let outputData = try pipe.fileHandleForReading.readToEnd() {
                    outputString = String(data: outputData, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                
                process.waitUntilExit()
                continuation.resume(returning: outputString)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Command Enum
extension ShellExecutor {
    enum Command: String, CaseIterable, Identifiable {
        case cleanArchives = "clean_archives"
        case cleanCaches = "clean_xcode_caches"
        case cleanDerivedData = "clean_derived_data"
        case cleanDeviceSupport = "clean_device_support"
        case cleanSimulatorData = "clean_simulator_data"
        case pruneOldSimulators = "prune_old_simulators"
        case resetXcodeSettings = "reset_xcode_settings"
        case calculateStorageUsage = "xcode_storage_usage"
        
        var id: String { rawValue }
        var scriptPath: String? { Bundle.main.path(forResource: rawValue, ofType: "sh") }
    }
}

// MARK: - Error Handling
extension ShellExecutor {
    enum ShellError: LocalizedError {
        case scriptNotFound(String)
        
        var errorDescription: String? {
            switch self {
            case .scriptNotFound(let name):
                return "⚠️ Script not found in app bundle: \(name).sh"
            }
        }
    }
}
