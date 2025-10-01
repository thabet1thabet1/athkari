#!/bin/bash

echo "Building signed release for Play Store..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build the app bundle (recommended for Play Store)
flutter build appbundle --release

echo ""
echo "✅ Build complete!"
echo "Your signed app bundle is located at:"
echo "build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Upload this .aab file to Google Play Console"