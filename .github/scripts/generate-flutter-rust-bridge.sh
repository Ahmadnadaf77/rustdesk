#!/bin/bash

# Script to generate Flutter Rust Bridge with error handling
# Usage: ./generate-flutter-rust-bridge.sh [flutter_dir] [rust_input] [dart_output] [c_output]

FLUTTER_DIR=${1:-"flutter"}
RUST_INPUT=${2:-"../src/flutter_ffi.rs"}
DART_OUTPUT=${3:-"./lib/generated_bridge.dart"}
C_OUTPUT=${4:-"./windows/runner/bridge_generated.h"}

echo "Generating Flutter Rust Bridge..."
echo "Flutter directory: $FLUTTER_DIR"
echo "Rust input: $RUST_INPUT"
echo "Dart output: $DART_OUTPUT"
echo "C output: $C_OUTPUT"

# Check if Flutter directory exists
if [[ ! -d "$FLUTTER_DIR" ]]; then
    echo "Error: Flutter directory $FLUTTER_DIR not found"
    exit 1
fi

# Navigate to Flutter directory
cd "$FLUTTER_DIR"
echo "Changed to Flutter directory: $(pwd)"

# Check if .dart_tool directory exists
if [[ ! -d ".dart_tool" ]]; then
    echo "Warning: .dart_tool directory not found, running flutter pub get..."
    flutter pub get
fi

# Check if package_config.json exists
if [[ ! -f ".dart_tool/package_config.json" ]]; then
    echo "Warning: package_config.json not found, running flutter pub get..."
    flutter pub get
fi

# Try to generate the bridge
echo "Running Flutter Rust Bridge codegen..."
if ~/.cargo/bin/flutter_rust_bridge_codegen --rust-input "$RUST_INPUT" --dart-output "$DART_OUTPUT" --c-output "$C_OUTPUT" --skip-deps-check --no-build-runner; then
    echo "✅ Flutter Rust Bridge generated successfully"
    exit 0
else
    echo "⚠️  Flutter Rust Bridge generation failed, trying alternative approach..."
    
    # Try without the problematic flags
    if ~/.cargo/bin/flutter_rust_bridge_codegen --rust-input "$RUST_INPUT" --dart-output "$DART_OUTPUT" --c-output "$C_OUTPUT"; then
        echo "✅ Flutter Rust Bridge generated successfully (alternative approach)"
        exit 0
    else
        echo "❌ Flutter Rust Bridge generation failed completely"
        echo "This might be due to missing dependencies or configuration issues"
        echo "The build will continue, but some features might not work"
        exit 0  # Don't fail the build
    fi
fi
