//
//  NavigationRouter.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

@Observable
final class NavigationRouter {
    var isSettingsPresented = false
}

extension EnvironmentValues {
    @Entry var navigationRouter = NavigationRouter()
}
