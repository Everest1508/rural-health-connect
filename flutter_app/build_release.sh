#!/bin/bash

# Build script for Flutter release
# Usage: ./build_release.sh [apk|appbundle|both]

set -e

BUILD_TYPE=${1:-both}
VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
BUILD_NUMBER=$(grep '^version:' pubspec.yaml | cut -d '+' -f 2)

echo "Building Rural Health Connect"
echo "Version: $VERSION"
echo "Build Number: $BUILD_NUMBER"
echo "Build Type: $BUILD_TYPE"

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Build based on type
if [ "$BUILD_TYPE" = "apk" ] || [ "$BUILD_TYPE" = "both" ]; then
    echo "Building APK..."
    flutter build apk --release
    
    # Create releases directory
    mkdir -p ../../releases/android
    
    # Copy APK to releases directory
    cp build/app/outputs/flutter-apk/app-release.apk "../../releases/android/rural-health-connect-v${VERSION}-build${BUILD_NUMBER}.apk"
    echo "APK built: releases/android/rural-health-connect-v${VERSION}-build${BUILD_NUMBER}.apk"
fi

if [ "$BUILD_TYPE" = "appbundle" ] || [ "$BUILD_TYPE" = "both" ]; then
    echo "Building App Bundle..."
    flutter build appbundle --release
    
    # Create releases directory
    mkdir -p ../../releases/android
    
    # Copy AAB to releases directory
    cp build/app/outputs/bundle/release/app-release.aab "../../releases/android/rural-health-connect-v${VERSION}-build${BUILD_NUMBER}.aab"
    echo "App Bundle built: releases/android/rural-health-connect-v${VERSION}-build${BUILD_NUMBER}.aab"
fi

echo "Build completed successfully!"

