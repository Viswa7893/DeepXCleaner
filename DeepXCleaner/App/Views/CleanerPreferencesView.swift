//
//  CleanerPreferencesView.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import SwiftUI

struct CleanerPreferencesView: View {
    @Environment(\.xcodeCleanerStore) private var store
    @Environment(\.cleanerPreferences) private var preferences
    @Environment(\.navigationRouter) private var router
    
    @State private var contentHeight: CGFloat = 0
    @Namespace private var animation
    
    var body: some View {
        @Bindable var prefs = preferences
        
        ZStack {
            // Background gradient (unchanged as requested)
            LinearGradient(colors: [.black.opacity(0.9), .indigo.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    header
                    
                    sectionCard("Cache", color: .blue) {
                        toggleRow("Remove Archives", systemImage: "archivebox.fill",
                                  detail: formatted(store.usedSpace.archives),
                                  isOn: $prefs.cleanArchives.value)
                        
                        toggleRow("Remove Caches", systemImage: "internaldrive.fill",
                                  detail: formatted(store.usedSpace.cache),
                                  isOn: $prefs.cleanCaches.value)
                        
                        toggleRow("Remove Derived Data", systemImage: "hammer.fill",
                                  detail: formatted(store.usedSpace.derivedData),
                                  isOn: $prefs.cleanDerivedData.value)
                    }
                    
                    sectionCard("Simulators & Xcode", color: .teal) {
                        toggleRow("Clear Device Support", systemImage: "cpu.fill",
                                  detail: formatted(store.usedSpace.deviceSupport),
                                  isOn: $prefs.cleanDeviceSupport.value)
                        
                        toggleRow("Clear Simulator Data", systemImage: "app.connected.to.app.below.fill",
                                  detail: formatted(store.usedSpace.simulatorData),
                                  isOn: $prefs.cleanSimulatorData.value)
                        
                        toggleRow("Remove Old Simulators", systemImage: "trash.fill",
                                  isOn: $prefs.pruneOldSimulators.value)
                        
                        toggleRow("Reset Xcode Preferences", systemImage: "gearshape.2.fill",
                                  isOn: $prefs.resetXcodeSettings.value)
                    }
                    
                    sectionCard("App Preferences", color: .purple) {
                        toggleRow("Show Free Space in Menu Bar", systemImage: "menubar.rectangle",
                                  isOn: $prefs.showFreeSpaceInMenuBar.value)
                    }
                    
                    Text("Version \(NSApplication.fullVersionString)")
                        .font(.footnote.bold())
                        .foregroundStyle(.white.opacity(0.5))
                    
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 48)
                .scrollContentHeight($contentHeight)
                .animation(.bouncy, value: store.freedSpace)
            }
        }
        .overlay(alignment: .topLeading) { backButton }
    }
}

// MARK: - UI Sections
private extension CleanerPreferencesView {
    
    var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 38))
                .symbolEffect(.bounce, options: .repeat(3))
                .foregroundStyle(.cyan)
            
            Text("Cleaner Preferences")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text("Customize what to clean and what to keep.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 6)
    }
    
    func sectionCard(
        _ title: String,
        color: Color,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            
            VStack(spacing: 12) {
                content()
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.06))
            )
            .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
        }
    }
    
    func toggleRow(
        _ title: LocalizedStringKey,
        systemImage: String,
        detail: String? = nil,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(isOn.wrappedValue ? .cyan : .white.opacity(0.6))
                .frame(width: 22)
                .symbolEffect(.bounce, value: isOn.wrappedValue)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isOn.wrappedValue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(.white)
                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(AnimatedToggleStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .opacity(isOn.wrappedValue ? 0.32 : 0.12)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isOn.wrappedValue ? .cyan.opacity(0.35) : .white.opacity(0.04), lineWidth: 1)
                )
        )
        .shadow(color: isOn.wrappedValue ? .cyan.opacity(0.22) : .clear, radius: 10, y: 3)
        .animation(.spring(response: 0.45, dampingFraction: 0.7), value: isOn.wrappedValue)
    }

    struct AnimatedToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        configuration.isOn
                        ? LinearGradient(colors: [.green, .mint, .yellow.opacity(0.9)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.3)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
                    )

                    .frame(width: 50, height: 26)
                    .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                        Circle()
                            .fill(.white)
                            .frame(width: 22, height: 22)
                            .shadow(radius: 2, y: 1)
                            .padding(2)
                            .offset(x: configuration.isOn ? -2 : 2)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isOn)
                    }
                    .onTapGesture { configuration.isOn.toggle() }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isOn)
            }
            .contentShape(Rectangle())
        }
    }

    
    var backButton: some View {
        Button {
            router.isSettingsPresented.toggle()
        } label: {
            Label("Home", systemImage: "chevron.backward")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .padding()
    }
}

// MARK: - Helper
private extension CleanerPreferencesView {
    func formatted(_ size: Int) -> String {
        Double(size).formattedBytes()
    }
}

// MARK: - Preview
#Preview {
    CleanerPreferencesView()
        .environment(\.xcodeCleanerStore, .init(.init()))
        .environment(\.cleanerPreferences, .init())
        .environment(\.navigationRouter, .init())
        .preferredColorScheme(.dark)
}
