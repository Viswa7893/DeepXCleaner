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
    let preferences: CleanerPreferences
    
    var status: Status {
        if isCleaning {
            .cleaning(progress: progress, total: progressTotal)
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
    private let shell = ShellExecutor()
    private var timer: Timer?
    private var isCompleted = false
    private var steps: [CleanerStep] = []
    
    private var progress: Double { Double(steps.count) }
    private var progressTotal: CGFloat { CGFloat(enabledCommands.count) }
    
    private var enabledCommands: [ShellExecutor.Command] {
        [
            preferences.cleanArchives,
            preferences.cleanCaches,
            preferences.cleanDerivedData,
            preferences.pruneOldSimulators,
            preferences.cleanDeviceSupport,
            preferences.cleanSimulatorData,
            preferences.resetXcodeSettings
        ]
        .filter{ $0.value }
        .compactMap { .init(rawValue: $0.key) }
    }
    
    // MARK: - Init
    init(_ preferences: CleanerPreferences) {
        self.preferences = preferences
        setupTimer()
        
        defer {
            setupTimer()
            calculateUsage()
        }
    }
    
    // MARK: - Public Methods
    @MainActor
    func clean() async throws {
        isCleaning = true
        isCompleted = false
        
        await withTaskGroup(of: CleanerStep.self) { group in
            enabledCommands.enumerated().forEach { index, command in
                group.addTask(priority: .background) { [weak self] in
                    do {
                        try await self?.shell.execute(command)
                        return await .init(command.id, error: nil)
                    } catch {
                        return await .init(command.id, error: error)
                    }
                }
            }
            
            while let step = await group.next() {
                try? await Task.sleep(nanoseconds: 1.second / 2) // 0.5 sec
                steps.append(step)
            }
        }
        
        calculateUsage()
        try? await Task.sleep(nanoseconds: 1.second)
        
        isCleaning = false
        isCompleted = true
        steps.removeAll()
        
        try? await Task.sleep(nanoseconds: 2.second)
        isCompleted = false
    }
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Private Methods
    private func setupTimer() {
        timer = .scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.calculateUsage()
        }
    }
    
    private func calculateUsage() {
        isCalculating = true
        Task(priority: .background) { @MainActor in
            let output = try? await shell.execute(.calculateStorageUsage)
            usedSpace = (try? output?.data(using: .utf8)?.decoder()) ?? .init()
            isCalculating = false
        }
    }
    
    private func size(of command: ShellExecutor.Command) -> Int {
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

private struct CleanerStep: Equatable, Identifiable {
    let id: String
    let error: Error?
    var hasError: Bool { error != nil }
    init(_ id: String, error: Error?) {
        self.id = id
        self.error = error
    }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
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
