#!/bin/bash
# Code Obfuscation and Crashlytics Symbol Upload Script
# This script fulfills Phase E1 requirements.

echo "Building Android Release with Obfuscation..."
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android

# Note: iOS build must be run on macOS.
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS Release with Obfuscation..."
    flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
else
    echo "Skipping iOS build (not running on macOS)."
fi

echo "Uploading symbols to Firebase Crashlytics..."
# Using Firebase CLI (requires firebase-tools installed and logged in)
# Make sure to set your app id or run within an initialized firebase project.

# Upload android symbols
# firebase crashlytics:symbols:upload --app=<AG_ANDROID_APP_ID> build/symbols/android
echo "Please ensure firebase-tools is installed and run: firebase crashlytics:symbols:upload --app=<YOUR_APP_ID> build/symbols/android"

echo "Symbols generated and split into build/symbols/. Securely store this directory."
