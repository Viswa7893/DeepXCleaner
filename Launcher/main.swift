//
//  main.swift
//  AutoLauncher
//
//  Created by IT SF GOC HYD on 17/11/25.
//


import Cocoa

private func startApp() {
    DispatchQueue.main.async {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
    // Enter the main dispatch loop to keep the process alive until NSApplicationMain takes over
    dispatchMain()
}

autoreleasepool {
    // Ensure startup happens on the main actor to satisfy @MainActor-isolated delegate conformance
    startApp()
}
