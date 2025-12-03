//
//  XcodeCleanerView.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

struct XcodeCleanerView: View {
    
    // MARK: - Environment
    @Environment(\.xcodeCleanerStore) private var store
    @Environment(\.navigationRouter) private var navigationRouter
    @Environment(\.openURL) private var openURL
    
    // MARK: - State
    @State private var cleaningTask: Task<Void, Error>?
    @State private var isHoveringQuit = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo.opacity(0.25), .black.opacity(0.85)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 22) {
                headerSection
                mainCard
                HStack(spacing: 14) {
                    HoverButton {
                        navigationRouter.isSettingsPresented.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    socialSection

                    quitButton
                }
            }
            .padding(.vertical, 24)
            .padding(.trailing, 30)
            .padding(.leading, 30)
            
        }
        .animation(.easeInOut(duration: 0.28), value: store.status)
    }
}

// MARK: - UI Sections
private extension XcodeCleanerView {
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(.cyan)
                    .symbolEffect(.bounce)
                
                Text("DeepXCleaner")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            Text("Keep your Xcode workspace fresh & fast 💨")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    var mainCard: some View {
        ZStack {
            // Glass container
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(LinearGradient(colors: [.white.opacity(0.06), .white.opacity(0.02)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 30, y: 12)
            
            
            VStack {
                ZStack {
                    CircularProgressView(progress: progressValue)
                        .frame(width: 110, height: 110)
                }
                
                if store.isCleaning {
                    Text("Cleaning in progress...")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else if store.status == .completed {
                    Text("🎉 All clean! Enjoy your space.")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Ready")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                VStack(spacing: 10){
                    CleanerActionButton(
                        status: store.status,
                        freeSpace: store.freedSpace
                    ) { startCleaning() }
                    
                    Label("Total Cache Size : \(Double(store.usedSpace.totalSize).formattedBytes())", systemImage: "internaldrive.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    var progressValue: Double {
        switch store.status {
        case .idle:
            return 0.0
        case .cleaning(let progress, _):
            return progress
        case .completed:
            return 1.0
        case .error:
            return 0.0
        }
    }
    
    @ViewBuilder
    var statusDetails: some View {
        if store.isCleaning {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cleaning in progress…")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
        } else if store.status == .completed {
            Text("All clean! Enjoy your space.")
                .font(.subheadline)
                .foregroundStyle(.green)
                .transition(.opacity)
        }
    }
    
    // MARK: - New Separated Social Section (compact)
    var socialSection: some View {
        HStack {
            ForEach(socials, id: \.0) { item in
                SocialLinkButton(image: item.0, colors: item.1, url: item.2)
            }
        }
    }
    
    var socials: [(String, [Color], String)] {
        [
            ("github.fill", [Color.yellow, Color.orange, Color.pink], "https://viswa7893.github.io"),
            ("linkedin", [Color(hex: "#43C6AC"), Color(hex: "#191654")], "https://www.linkedin.com/in/nemala-durga-viswanadh/"),
            ("envelope.fill", [Color.orange, Color.pink, Color.red], "mailto:durgaviswanadhnemala@gmail.com")
        ]
    }
    
    var footerSection: some View {
        HStack(spacing: 12) {
            Text("Version \(NSApplication.fullVersionString)")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))
            
            Spacer()
            
            quitButton
        }
        .font(.footnote)
    }
    
    var quitButton: some View {
        Button(action: store.quit) {
            Text("Quit")
            .foregroundStyle(.white.opacity(0.5))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(isHoveringQuit ? 0.12 : 0.04))
            .cornerRadius(10)
            .onHover { isHoveringQuit = $0 }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Actions
private extension XcodeCleanerView {
    func startCleaning() {
        guard !store.isCleaning else { return }
        cleaningTask?.cancel()
        cleaningTask = Task(priority: .userInitiated) { @MainActor in
            do { try await store.clean() } catch { print(error) }
        }
    }
}

// MARK: - Cleaner Action Button (unchanged logic, refreshed styling)
private struct CleanerActionButton: View {
    @State private var isHover = false
    let status: XcodeCleanerStore.Status
    let freeSpace: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(buttonTitle)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: gradientColors.last!.opacity(0.28), radius: 18, y: 8)
            )
            .scaleEffect(isHover ? 1.04 : 1)
            .animation(.spring(response: 0.36, dampingFraction: 0.68), value: isHover)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
        .onHover { isHover = $0 }
    }
    
    var isDisabled: Bool {
        switch status {
        case .cleaning:
            return true
        default:
            return false
        }
    }
}

private extension CleanerActionButton {
    var gradientColors: [Color] {
        switch status {
        case .idle: return [.mint, .teal, .indigo]
        case .cleaning: return [.orange, .red]
        case .completed: return [.green, .mint]
        case .error: return [.red, .orange]
        }
    }
    
    var buttonTitle: String {
        switch status {
        case .cleaning: "Cleaning..."
        case .error: "Try Again"
        case .completed: "🎉 Cleaned!"
        case .idle:
            freeSpace.isZero ? "Clear Now" : "Clear \(freeSpace.formattedBytes())"
        }
    }
}

// MARK: - Circular progress (simple, aesthetic)
private struct CircularProgressView: View {
    let progress: Double // 0..1
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 10)
            Circle()
                .trim(from: 0, to: min(max(progress, 0.0), 1.0))
                .stroke(AngularGradient(gradient: Gradient(colors: [.blue, .purple, .cyan]), center: .center), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.cyan.opacity(0.35), radius: 8, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.3), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .frame(width: 70, height: 70)
    }
}

// MARK: - Social Link Button (unchanged)
private struct SocialLinkButton: View {
    @Environment(\.openURL) private var openURL
    let image: String
    let colors: [Color]
    let url: String
    @State private var isHovering = false
    
    var body: some View {
        Button {
            if let link = URL(string: url) {
                openURL(link)
            }
        } label: {
            iconView
                .padding(14)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(colors: colors,
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: colors.last!.opacity(isHovering ? 0.75 : 0.32),
                                radius: isHovering ? 14 : 8,
                                y: isHovering ? 6 : 3)
                        .frame(width: 30, height: 30)
                )
                .scaleEffect(isHovering ? 1.12 : 1)
                .rotationEffect(.degrees(isHovering ? 4 : 0))
                .animation(.spring(response: 0.45, dampingFraction: 0.65), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
    
    // MARK: - Smart icon renderer
    @ViewBuilder
    private var iconView: some View {
        if NSImage(named: image) != nil {
            Image(image)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 15, height: 15)
        } else {
            Image(systemName: image)
                .font(.body)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    XcodeCleanerView()
        .environment(\.xcodeCleanerStore, .init(.init()))
        .environment(\.navigationRouter, .init())
        .preferredColorScheme(.dark)
}
