//
//  Int+Extension.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


extension Int {
    var second: UInt64 {
        UInt64(self) * UInt64(1_000_000_000)
    }
    
    func toDouble() -> Double {
        Double(self)
    }
}
