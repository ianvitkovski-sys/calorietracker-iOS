#!/bin/bash
# Setup script for CalorieTracker
# Run on macOS: bash setup.sh

echo "Setting up CalorieTracker iOS project..."

# Check for Xcode
if ! command -v xcodebuild &>/dev/null; then
    echo "Error: Xcode is required but not found."
    exit 1
fi

# Check for xcodegen
if ! command -v xcodegen &>/dev/null; then
    echo "xcodegen not found. Installing via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew is required to install xcodegen."
        echo "Install Homebrew: https://brew.sh"
        exit 1
    fi
    brew install xcodegen
fi

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen

# Open in Xcode
echo "Opening in Xcode..."
open CalorieTracker.xcodeproj

echo ""
echo "Setup complete!"
echo ""
echo "Before running:"
echo "1. Add FoodDetector.mlmodel to CalorieTracker/Models/"
echo "2. Add your USDA API key to the Xcode scheme environment variables"
echo "   (Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables)"
echo "3. Select a simulator or device and press Cmd+R"
