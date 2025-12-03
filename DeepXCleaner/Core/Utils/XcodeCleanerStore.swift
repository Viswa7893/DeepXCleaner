//
//  XcodeCleanerStore.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import SwiftUI

@Observable
final class XcodeCleanerStore {
    
    // MARK: - Public Properties
    private(set) var usedSpace = XcodeStorageUsage()
    private(set) var isCalculating = false
    private(set) var isCleaning = false
    private(set) var animatedProgress: Double = 0.0  // For smooth UI animation
    let preferences: CleanerPreferences
    
    var status: Status {
        if isCleaning {
            .cleaning(progress: animatedProgress, total: progressTotal)
        } else if isCompleted {
            .completed
        } else {
            .idle
        }
    }
    
    var freedSpace: Double {
        enabledCommands.reduce(0) { partial, command in
            partial + size(of: command)
        }.toDouble()
    }
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var isCompleted = false
    private var completedSteps: Int = 0
    private var totalSteps: Int = 0
    
    private var progressTotal: CGFloat { 1.0 }
    
    private var enabledCommands: [CleanCommand] {
        var commands: [CleanCommand] = []
        
        if preferences.cleanArchives.value {
            commands.append(.cleanArchives)
        }
        if preferences.cleanCaches.value {
            commands.append(.cleanCaches)
        }
        if preferences.cleanDerivedData.value {
            commands.append(.cleanDerivedData)
        }
        if preferences.pruneOldSimulators.value {
            commands.append(.pruneOldSimulators)
        }
        if preferences.cleanDeviceSupport.value {
            commands.append(.cleanDeviceSupport)
        }
        if preferences.cleanSimulatorData.value {
            commands.append(.cleanSimulatorData)
        }
        if preferences.resetXcodeSettings.value {
            commands.append(.resetXcodeSettings)
        }
        
        return commands
    }
    
    // MARK: - Init
    init(_ preferences: CleanerPreferences) {
        self.preferences = preferences
        setupTimer()
        calculateUsage()
    }
    
    // MARK: - Public Methods
    @MainActor
    func clean() async throws {
        isCleaning = true
        isCompleted = false
        completedSteps = 0
        animatedProgress = 0.0
        
        // Stop timer during cleaning to avoid conflicts
        timer?.invalidate()
        
        let commands = enabledCommands
        totalSteps = commands.count
        
        guard totalSteps > 0 else {
            isCleaning = false
            return
        }
        
        // Execute commands with smooth progress updates
        for (index, command) in commands.enumerated() {
            // Calculate progress range for this command
            let startProgress = Double(index) / Double(totalSteps)
            let endProgress = Double(index + 1) / Double(totalSteps)
            
            // Start animating progress for this command
            let animationTask = Task { @MainActor in
                await animateProgress(from: startProgress, to: endProgress, duration: 2.0)
            }
            
            // Execute the actual command
            do {
                try await executeCleanCommand(command)
            } catch {
                print("Error executing \(command): \(error)")
            }
            
            // Wait for animation to complete
            await animationTask.value
            
            // Mark as complete
            completedSteps = index + 1
            animatedProgress = endProgress
            
            // Small pause between commands
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec
        }
        
        // Ensure we reach 100%
        animatedProgress = 1.0
        completedSteps = totalSteps
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 sec
        
        // Recalculate storage after cleaning
        await calculateUsageAsync()
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
        
        isCleaning = false
        isCompleted = true
        completedSteps = 0
        totalSteps = 0
        animatedProgress = 0.0
        
        // Restart timer
        setupTimer()
        
        // Reset completion state after delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 sec
        isCompleted = false
    }
    
    // MARK: - Smooth Progress Animation
    @MainActor
    private func animateProgress(from start: Double, to end: Double, duration: TimeInterval) async {
        let steps = 60 // 60 updates for smooth animation
        let increment = (end - start) / Double(steps)
        let delayPerStep = duration / Double(steps)
        
        for step in 0...steps {
            animatedProgress = start + (increment * Double(step))
            try? await Task.sleep(nanoseconds: UInt64(delayPerStep * 1_000_000_000))
        }
        
        // Ensure we hit the exact end value
        animatedProgress = end
    }
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Private Methods
    private func setupTimer() {
        timer?.invalidate()
        timer = .scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self, !self.isCleaning else { return }
            self.calculateUsage()
        }
    }
    
    private func calculateUsage() {
        guard !isCalculating else { return }
        
        Task(priority: .background) {
            await calculateUsageAsync()
        }
    }
    
    @MainActor
    private func calculateUsageAsync() async {
        isCalculating = true
        
        let usage = await Task.detached(priority: .background) {
            await FileOperations.calculateStorageUsage()
        }.value
        
        usedSpace = usage
        isCalculating = false
    }
    
    private func executeCleanCommand(_ command: CleanCommand) async throws {
        try await Task.detached(priority: .userInitiated) {
            try await FileOperations.executeClean(command)
        }.value
    }
    
    private func size(of command: CleanCommand) -> Int {
        switch command {
        case .cleanArchives: usedSpace.archives
        case .cleanCaches: usedSpace.cache
        case .cleanDerivedData: usedSpace.derivedData
        case .cleanDeviceSupport: usedSpace.deviceSupport
        case .cleanSimulatorData: usedSpace.simulatorData
        default: 0
        }
    }
}

// MARK: - Nested Types
extension XcodeCleanerStore {
    enum Status: Equatable {
        case idle
        case completed
        case cleaning(progress: Double, total: Double)
        case error
    }
}

// MARK: - Clean Commands
enum CleanCommand: String, CaseIterable {
    case cleanArchives
    case cleanCaches
    case cleanDerivedData
    case cleanDeviceSupport
    case cleanSimulatorData
    case pruneOldSimulators
    case resetXcodeSettings
}

// MARK: - File Operations (Pure Swift, No Shell Scripts)
actor FileOperations {
    
    static func calculateStorageUsage() async -> XcodeStorageUsage {
        let fm = FileManager.default
        let homeDir = fm.homeDirectoryForCurrentUser.path
        
        // Calculate all sizes
        let derivedData = await calculateDirectorySize("\(homeDir)/Library/Developer/Xcode/DerivedData/")
        let archives = await calculateDirectorySize("\(homeDir)/Library/Developer/Xcode/Archives")
        let simulatorData = await calculateDirectorySize("\(homeDir)/Library/Developer/CoreSimulator")
        let xcodeCache = await calculateDirectorySize("\(homeDir)/Library/Caches/com.apple.dt.Xcode")
        let carthageCache = await calculateDirectorySize("\(homeDir)/Library/Caches/org.carthage.CarthageKit")
        let deviceSupportIOS = await calculateDirectorySize("\(homeDir)/Library/Developer/Xcode/iOS DeviceSupport")
        let deviceSupportWatchOS = await calculateDirectorySize("\(homeDir)/Library/Developer/Xcode/watchOS DeviceSupport")
        let deviceSupportTvOS = await calculateDirectorySize("\(homeDir)/Library/Developer/Xcode/tvOS DeviceSupport")
        
        // Return initialized struct
        return await XcodeStorageUsage(
            derivedData: derivedData,
            archives: archives,
            simulatorData: simulatorData,
            xcodeCache: xcodeCache,
            carthageCache: carthageCache,
            deviceSupportIOS: deviceSupportIOS,
            deviceSupportWatchOS: deviceSupportWatchOS,
            deviceSupportTvOS: deviceSupportTvOS
        )
    }
    
    static func executeClean(_ command: CleanCommand) async throws {
        let fm = FileManager.default
        let homeDir = fm.homeDirectoryForCurrentUser.path
        
        switch command {
        case .cleanArchives:
            try await removeDirectory("\(homeDir)/Library/Developer/Xcode/Archives")
            
        case .cleanCaches:
            try await removeDirectory("\(homeDir)/Library/Caches/com.apple.dt.Xcode")
            try await removeDirectory("\(homeDir)/Library/Caches/org.carthage.CarthageKit")
            
        case .cleanDerivedData:
            try await removeDirectory("\(homeDir)/Library/Developer/Xcode/DerivedData/")
            
        case .cleanDeviceSupport:
            try await removeDirectory("\(homeDir)/Library/Developer/Xcode/iOS DeviceSupport")
            try await removeDirectory("\(homeDir)/Library/Developer/Xcode/watchOS DeviceSupport")
            try await removeDirectory("\(homeDir)/Library/Developer/Xcode/tvOS DeviceSupport")
            
        case .cleanSimulatorData:
            try await removeDirectory("\(homeDir)/Library/Developer/CoreSimulator")
            
        case .pruneOldSimulators:
            try await executeProcess("/usr/bin/xcrun", arguments: ["simctl", "delete", "unavailable"])
            
        case .resetXcodeSettings:
            try await executeProcess("/usr/bin/defaults", arguments: ["delete", "com.apple.dt.Xcode"])
        }
    }
    
    // MARK: - Helper Methods
    
    private static func calculateDirectorySize(_ path: String) async -> Int {
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: path) else { return 0 }
        
        // Use du -sk for accurate disk usage calculation (matches original behavior)
        // This is more accurate than manually enumerating files because it accounts
        // for filesystem block allocation
        do {
            let result = try await executeProcessWithOutput("/usr/bin/du", arguments: ["-sk", path])
            
            // Parse output: "123456\t/path/to/directory"
            if let firstComponent = result.components(separatedBy: "\t").first,
               let sizeInKB = Int(firstComponent.trimmingCharacters(in: .whitespaces)) {
                return sizeInKB
            }
            
            return 0
        } catch {
            // Fallback: return 0 if du command fails
            return 0
        }
    }
    
    private static func executeProcessWithOutput(_ executablePath: String, arguments: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = arguments
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            process.terminationHandler = { process in
                if process.terminationStatus == 0 {
                    if let data = try? pipe.fileHandleForReading.readToEnd(),
                       let output = String(data: data, encoding: .utf8) {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(returning: "")
                    }
                } else {
                    continuation.resume(throwing: CleanError.processFailed(status: process.terminationStatus))
                }
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private static func removeDirectory(_ path: String) async throws {
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: path) else { return }
        
        try fm.removeItem(atPath: path)
    }
    
    private static func executeProcess(_ executablePath: String, arguments: [String]) async throws {
        // Reuse executeProcessWithOutput but discard the output
        _ = try await executeProcessWithOutput(executablePath, arguments: arguments)
    }
}

enum CleanError: LocalizedError {
    case processFailed(status: Int32)
    
    var errorDescription: String? {
        switch self {
        case .processFailed(let status):
            return "Process failed with status: \(status)"
        }
    }
}

// MARK: - Environment Injection
extension EnvironmentValues {
    @Entry var xcodeCleanerStore = XcodeCleanerStore(.init())
}

// MARK: - Data
extension Data {
    func decoder<T: Decodable>(decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}
