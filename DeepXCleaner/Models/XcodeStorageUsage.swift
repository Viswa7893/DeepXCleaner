//
//  XcodeStorageUsage.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import Foundation

struct XcodeStorageUsage: Decodable {
    let derivedData: Int
    let archives: Int
    let simulatorData: Int
    let xcodeCache: Int
    let carthageCache: Int
    let deviceSupportIOS: Int
    let deviceSupportWatchOS: Int
    let deviceSupportTvOS: Int

    enum CodingKeys: String, CodingKey {
        case derivedData = "derived_data"
        case archives
        case simulatorData = "simulator_data"
        case xcodeCache = "xcode_cache"
        case carthageCache = "carthage_cache"
        case deviceSupportIOS = "device_support_ios"
        case deviceSupportWatchOS = "device_support_watchos"
        case deviceSupportTvOS = "device_support_tvos"
    }

    var cache: Int {
        xcodeCache + carthageCache
    }

    var deviceSupport: Int {
        deviceSupportIOS + deviceSupportWatchOS + deviceSupportTvOS
    }

    var totalSize: Int {
        derivedData + archives + simulatorData + cache + deviceSupport
    }

    init(
        derivedData: Int = 0,
        archives: Int = 0,
        simulatorData: Int = 0,
        xcodeCache: Int = 0,
        carthageCache: Int = 0,
        deviceSupportIOS: Int = 0,
        deviceSupportWatchOS: Int = 0,
        deviceSupportTvOS: Int = 0
    ) {
        self.derivedData = derivedData
        self.archives = archives
        self.simulatorData = simulatorData
        self.xcodeCache = xcodeCache
        self.carthageCache = carthageCache
        self.deviceSupportIOS = deviceSupportIOS
        self.deviceSupportWatchOS = deviceSupportWatchOS
        self.deviceSupportTvOS = deviceSupportTvOS
    }
}
