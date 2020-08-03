#!/bin/bash

rm -rf "./build"

xcodebuild archive \
    -project "./$1" \
    -scheme $2 \
    -archivePath "./build/ios.xcarchive" \
    -sdk iphoneos \
    SKIP_INSTALL=NO

xcodebuild archive \
    -project "./$1" \
    -scheme $2 \
    -archivePath "./build/ios_sim.xcarchive" \
    -sdk iphonesimulator \
    -arch x86_64 \
    SKIP_INSTALL=NO


xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/$3.framework" \
    -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/$3.framework" \
    -output "./build/$3.xcframework"

