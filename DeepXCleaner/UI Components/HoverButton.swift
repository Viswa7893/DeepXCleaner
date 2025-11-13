//
//  HoverButton.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

struct HoverButton<Label: View>: View {
    @State private var isHover = false
    private let action: () -> Void
    private let label: () -> Label

    init(_ action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            label()
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(isHover ? 0.1 : 0))
                )
        }
        .buttonStyle(.plain)
        .onHover { isHover = $0 }
        .animation(.snappy.speed(2), value: isHover)
    }
}
