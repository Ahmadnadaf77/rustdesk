#!/bin/bash

# Windows Build Script for RustDesk
# This script sets up the build process and provides multiple options

set -e

echo "🚀 RustDesk Windows Build Script"
echo "================================="

# Check if we're in the right directory
if [ ! -f "Cargo.toml" ] || [ ! -d "flutter" ]; then
    echo "❌ Error: Please run this script from the RustDesk root directory"
    exit 1
fi

# Create output directory
OUTPUT_DIR="/home/ahmad-nadaf/windesk_new_build_windows"
echo "📁 Output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "🔧 Build Options:"
echo "1. GitHub Actions (Recommended - Automated)"
echo "2. Docker Windows Container (Advanced)"
echo "3. Manual Windows Build Instructions"
echo "4. Copy current Linux build to output directory"
echo ""

read -p "Choose option (1-4): " choice

case $choice in
    1)
        echo "📋 Setting up GitHub Actions build..."
        
        # Check if git is initialized
        if [ ! -d ".git" ]; then
            echo "🔧 Initializing git repository..."
            git init
            git add .
            git commit -m "Initial commit with custom server configuration"
        fi
        
        echo "📝 GitHub Actions workflow is ready at: .github/workflows/build-windows.yml"
        echo ""
        echo "📋 Next steps:"
        echo "1. Push to GitHub:"
        echo "   git remote add origin <your-github-repo-url>"
        echo "   git push -u origin main"
        echo ""
        echo "2. Go to GitHub Actions tab in your repository"
        echo "3. Run the 'Build Windows Release' workflow"
        echo "4. Download the build artifacts"
        echo "5. Extract to: $OUTPUT_DIR"
        echo ""
        echo "✅ GitHub Actions setup complete!"
        ;;
        
    2)
        echo "🐳 Setting up Docker Windows build..."
        echo ""
        echo "⚠️  Note: This requires Windows containers and Docker Desktop with Windows support"
        echo ""
        echo "📋 To build with Docker:"
        echo "1. Enable Windows containers in Docker Desktop"
        echo "2. Run: docker build -f Dockerfile.windows -t rustdesk-windows ."
        echo "3. Run: docker run -v $OUTPUT_DIR:/output rustdesk-windows"
        echo ""
        echo "✅ Docker setup complete!"
        ;;
        
    3)
        echo "📖 Manual Windows Build Instructions:"
        echo ""
        echo "📋 Prerequisites:"
        echo "- Windows 10/11 machine"
        echo "- Visual Studio 2022 with C++ build tools"
        echo "- Rust toolchain (stable)"
        echo "- Flutter SDK (3.35.6+)"
        echo ""
        echo "📋 Build Commands:"
        echo "1. Copy this project to Windows machine"
        echo "2. Open PowerShell as Administrator"
        echo "3. Run:"
        echo "   cd rustdesk"
        echo "   cd flutter"
        echo "   flutter pub get"
        echo "   cd .."
        echo "   cargo build --release"
        echo "   cd flutter"
        echo "   flutter build windows --release"
        echo ""
        echo "4. Copy build output from:"
        echo "   flutter/build/windows/x64/runner/Release/"
        echo "   to: $OUTPUT_DIR"
        echo ""
        echo "✅ Manual build instructions provided!"
        ;;
        
    4)
        echo "📁 Copying Linux build to output directory..."
        
        if [ -d "flutter/build/linux/x64/release/bundle" ]; then
            cp -r flutter/build/linux/x64/release/bundle/* "$OUTPUT_DIR/"
            echo "✅ Linux build copied to: $OUTPUT_DIR"
            echo ""
            echo "📋 Contents:"
            ls -la "$OUTPUT_DIR"
        else
            echo "❌ Linux build not found. Please run 'flutter build linux --release' first."
        fi
        ;;
        
    *)
        echo "❌ Invalid option. Please choose 1-4."
        exit 1
        ;;
esac

echo ""
echo "🎯 Your custom server configuration is already set:"
echo "   ID Server: 171.22.24.28:21116"
echo "   API Server: https://171.22.24.28"
echo "   Public Key: 8HKCcJSQXbsgojo0gjrTg8uh7Kzfz+NS35lgIbWb0Vw="
echo ""
echo "✅ Build setup complete!"
