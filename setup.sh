#!/bin/bash

set -e

echo "🚀 Setting up Look Up, Silly! iOS project..."

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "❌ xcodegen is not installed"
    echo "Please install it with: brew install xcodegen"
    exit 1
fi

# Generate Xcode project
echo "📦 Generating Xcode project with xcodegen..."
xcodegen generate

echo "✅ Project generated successfully!"
echo ""
echo "Next steps:"
echo "1. Open LookUpSilly-iOS.xcodeproj"
echo "2. Select your development team in Signing & Capabilities"
echo "3. Add app icons to LookUpSilly/Assets.xcassets/AppIcon.appiconset/"
echo "4. Build and run!"
echo ""
echo "To open the project now, run:"
echo "  open LookUpSilly-iOS.xcodeproj"

