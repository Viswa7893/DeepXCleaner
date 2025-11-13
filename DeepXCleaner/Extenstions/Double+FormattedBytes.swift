//
//  Double+FormattedBytes.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//

import Foundation

extension Double {
    func formattedBytes() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(from: .init(value: self, unit: .kilobytes))
    }
}
