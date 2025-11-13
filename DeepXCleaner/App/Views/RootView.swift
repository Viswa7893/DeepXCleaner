//
//  ContentView.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import SwiftUI

struct RootView: View {
    @Environment(\.navigationRouter) private var router

    var body: some View {
        Group {
            if router.isSettingsPresented {
                CleanerPreferencesView()
                    .frame(width: 450, height: 700)
                    .transition(.move(edge: .trailing))
            } else {
                XcodeCleanerView()
                    .frame(width: 350)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: router.isSettingsPresented)
    }
}

#Preview {
    RootView()
        .environment(\.cleanerPreferences, .init())
        .environment(\.navigationRouter, .init())
}
