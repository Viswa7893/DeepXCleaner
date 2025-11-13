#!/bin/sh

#  clean_xcode_caches.sh
#  DeepXCleaner
#
#  Created by Durga Viswanadh on 10/11/25.
#

# Clean Xcode and Carthage caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Caches/org.carthage.CarthageKit

# Clean CocoaPods cache if available
if command -v pod &>/dev/null; then
    pod cache clean --all
fi
