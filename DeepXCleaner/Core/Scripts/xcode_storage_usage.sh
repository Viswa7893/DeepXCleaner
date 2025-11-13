#!/bin/sh

#  xcode_storage_usage.sh
#  DeepXCleaner
#
#  Created by Durga Viswanadh on 10/11/25.
#

# Define paths with readable keys
#!/bin/bash

# Define key/path pairs
paths=(
    "derived_data $HOME/Library/Developer/Xcode/DerivedData/"
    "archives $HOME/Library/Developer/Xcode/Archives"
    "simulator_data $HOME/Library/Developer/CoreSimulator"
    "xcode_cache $HOME/Library/Caches/com.apple.dt.Xcode"
    "carthage_cache $HOME/Library/Caches/org.carthage.CarthageKit"
    "device_support_ios $HOME/Library/Developer/Xcode/iOS DeviceSupport"
    "device_support_watchos $HOME/Library/Developer/Xcode/watchOS DeviceSupport"
    "device_support_tvos $HOME/Library/Developer/Xcode/tvOS DeviceSupport"
)

infos=()

# Collect sizes
for entry in "${paths[@]}"; do
    read -a pair <<< "$entry"
    
    key="${pair[0]}"
    path="${pair[@]:1}"   # supports paths with spaces
    
    if [ -d "$path" ]; then
        size=$(du -sk "$path" | cut -f1)
    else
        size=0
    fi

    infos+=("$key $size")
done

# Build JSON output
json=""
for info in "${infos[@]}"; do
    read -a pair <<< "$info"
    key="${pair[0]}"
    value="${pair[1]}"

    if [ -n "$json" ]; then
        json+=","
    fi

    json+="\"$key\": $value"
done

echo "{${json}}"
