//
//  PersistentValue.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

@Observable
final class PersistentValue<T: Codable> {
    
    // MARK: - Public Variables
    
    private(set) var key: String
    
    var value: T {
        didSet {
            if let data = try? JSONEncoder().encode(value) {
                userDefaults.setValue(data, forKey: key)
            }
        }
    }
    
    // MARK: - Private Variables
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initializers
    
    init(
        _ key: String,
        value: T? = nil,
        defaultValue: T
    ) {
        self.key = key
        
        if let data = userDefaults.value(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(T.self, from: data) {
            self.value = value
        } else {
            self.value = value ?? defaultValue
        }
    }
}
