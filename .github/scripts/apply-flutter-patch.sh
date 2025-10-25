#!/bin/bash

# Script to safely apply Flutter patch with error handling
# Usage: ./apply-flutter-patch.sh [flutter_version] [patch_file]

FLUTTER_VERSION=${1:-"3.24.5"}
PATCH_FILE=${2:-".github/patches/flutter_3.24.5_dropdown_menu_enableFilter.diff"}

echo "Checking Flutter patch for version: $FLUTTER_VERSION"

# Check if we're in the right directory
if [[ ! -f "$PATCH_FILE" ]]; then
    echo "Error: Patch file $PATCH_FILE not found"
    exit 1
fi

# Navigate to Flutter directory
FLUTTER_DIR=$(dirname $(dirname $(which flutter)))
if [[ ! -d "$FLUTTER_DIR" ]]; then
    echo "Error: Flutter directory not found"
    exit 1
fi

cd "$FLUTTER_DIR"
echo "Changed to Flutter directory: $FLUTTER_DIR"

# Check if patch should be applied
if [[ "$FLUTTER_VERSION" == "3.24.5" ]]; then
    echo "Attempting to apply Flutter patch..."
    if git apply "$PATCH_FILE"; then
        echo "✅ Flutter patch applied successfully"
        exit 0
    else
        echo "⚠️  Warning: Flutter patch failed to apply, continuing without patch"
        echo "This is not critical and the build will continue"
        exit 0
    fi
else
    echo "Skipping Flutter patch for version $FLUTTER_VERSION"
    exit 0
fi
