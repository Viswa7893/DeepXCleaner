//
//  ScrollHeightModifier.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

struct ScrollHeightModifier: ViewModifier {
    private let height: Binding<CGFloat>
    
    init(_ height: Binding<CGFloat>) {
        self.height = height
    }

    func body(content: Content) -> some View {
        content.onScrollGeometryChange(for: CGFloat.self) {
            $0.contentSize.height
        } action: { _, newHeight in
            height.wrappedValue = newHeight
        }
    }
}

extension View {
    func scrollContentHeight(_ height: Binding<CGFloat>) -> some View {
        modifier(ScrollHeightModifier(height))
    }
}
