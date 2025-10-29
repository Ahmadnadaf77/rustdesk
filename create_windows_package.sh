#!/bin/bash

# RustDesk Windows Package Creator
# This script helps you create a complete, working Windows package

set -e

echo "🚀 RustDesk Windows Package Creator"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "Cargo.toml" ] || [ ! -d "flutter" ]; then
    echo -e "${RED}❌ Error: Please run this script from the RustDesk root directory${NC}"
    exit 1
fi

echo -e "${BLUE}📋 This script will help you create a complete Windows package.${NC}"
echo ""
echo "The Windows build requires ALL of these files:"
echo "  ✓ rustdesk.exe            (main executable)"
echo "  ✓ flutter_windows.dll      (Flutter engine)"
echo "  ✓ librustdesk.dll          (RustDesk library)"
echo "  ✓ data/                    (Flutter assets folder)"
echo ""
echo -e "${YELLOW}⚠️  A single .exe file will NOT work!${NC}"
echo ""

# Check for existing Windows build
FLUTTER_RELEASE_DIR="flutter/build/windows/x64/runner/Release"
OUTPUT_DIR="rustdesk-windows-complete"

echo "Checking for existing Windows build..."
echo ""

if [ -d "$FLUTTER_RELEASE_DIR" ]; then
    echo -e "${GREEN}✓ Found existing Windows build!${NC}"
    echo ""
    
    # Check for required files
    MISSING_FILES=0
    
    if [ ! -f "$FLUTTER_RELEASE_DIR/rustdesk.exe" ]; then
        echo -e "${RED}✗ Missing: rustdesk.exe${NC}"
        MISSING_FILES=1
    else
        echo -e "${GREEN}✓ Found: rustdesk.exe${NC}"
    fi
    
    if [ ! -f "$FLUTTER_RELEASE_DIR/flutter_windows.dll" ]; then
        echo -e "${RED}✗ Missing: flutter_windows.dll${NC}"
        MISSING_FILES=1
    else
        echo -e "${GREEN}✓ Found: flutter_windows.dll${NC}"
    fi
    
    if [ ! -f "$FLUTTER_RELEASE_DIR/librustdesk.dll" ]; then
        echo -e "${YELLOW}⚠ Missing: librustdesk.dll (might be named differently)${NC}"
    else
        echo -e "${GREEN}✓ Found: librustdesk.dll${NC}"
    fi
    
    if [ ! -d "$FLUTTER_RELEASE_DIR/data" ]; then
        echo -e "${RED}✗ Missing: data/ folder${NC}"
        MISSING_FILES=1
    else
        echo -e "${GREEN}✓ Found: data/ folder${NC}"
    fi
    
    echo ""
    
    if [ $MISSING_FILES -eq 0 ]; then
        echo -e "${GREEN}✓ All required files found!${NC}"
        echo ""
        
        # Create complete package
        echo "Creating complete Windows package..."
        rm -rf "$OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
        
        # Copy all files
        cp -r "$FLUTTER_RELEASE_DIR/"* "$OUTPUT_DIR/"
        
        # Create a launcher script
        cat > "$OUTPUT_DIR/Start-RustDesk.bat" << 'EOF'
@echo off
cd /d "%~dp0"
start "" rustdesk.exe
EOF
        
        # Create README
        cat > "$OUTPUT_DIR/README.txt" << 'EOF'
RustDesk Windows Complete Package
==================================

This package contains all required files to run RustDesk on Windows.

Installation:
1. Extract this entire folder to any location
2. Double-click "rustdesk.exe" or "Start-RustDesk.bat"

IMPORTANT:
- Do NOT move rustdesk.exe without moving the other files!
- All files in this folder are required for RustDesk to work

Required Files:
- rustdesk.exe           (main executable)
- flutter_windows.dll    (Flutter engine)
- librustdesk.dll        (RustDesk library)
- data/                  (Flutter assets folder)

System Requirements:
- Windows 10 or later (64-bit)

Custom Server Configuration:
- ID Server: 171.22.24.28:21116
- API Server: https://171.22.24.28
- Public Key: 8HKCcJSQXbsgojo0gjrTg8uh7Kzfz+NS35lgIbWb0Vw=

For support, visit: https://github.com/rustdesk/rustdesk
EOF
        
        # Create zip file
        PACKAGE_NAME="rustdesk-windows-complete-$(date +%Y%m%d-%H%M%S).zip"
        
        if command -v zip &> /dev/null; then
            cd "$OUTPUT_DIR"
            zip -r "../$PACKAGE_NAME" ./*
            cd ..
            echo ""
            echo -e "${GREEN}✅ Complete package created!${NC}"
            echo ""
            echo "Package location:"
            echo -e "  ${BLUE}$(pwd)/$PACKAGE_NAME${NC}"
            echo ""
            echo "Extracted folder:"
            echo -e "  ${BLUE}$(pwd)/$OUTPUT_DIR/${NC}"
            echo ""
            echo "You can now:"
            echo "  1. Use the files in: $OUTPUT_DIR/"
            echo "  2. Distribute the zip file: $PACKAGE_NAME"
        else
            echo ""
            echo -e "${GREEN}✅ Complete package folder created!${NC}"
            echo ""
            echo "Location:"
            echo -e "  ${BLUE}$(pwd)/$OUTPUT_DIR/${NC}"
            echo ""
            echo -e "${YELLOW}Note: 'zip' command not found, skipping zip creation${NC}"
            echo "You can manually zip the folder or use the folder directly"
        fi
        
        echo ""
        echo -e "${GREEN}🎉 Success! Your complete Windows package is ready.${NC}"
        echo ""
        echo "To use on Windows:"
        echo "  1. Transfer the folder/zip to your Windows machine"
        echo "  2. Extract (if zipped)"
        echo "  3. Run rustdesk.exe from the extracted folder"
        echo ""
        
    else
        echo -e "${RED}❌ Build is incomplete or corrupted.${NC}"
        echo ""
        echo "The build needs to be regenerated."
    fi
    
else
    echo -e "${YELLOW}⚠️  No Windows build found at: $FLUTTER_RELEASE_DIR${NC}"
    echo ""
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}📋 How to Build RustDesk for Windows${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo "You have 3 options:"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Option 1: GitHub Actions (RECOMMENDED)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✓ Fully automated"
echo "✓ No Windows machine needed"
echo "✓ Creates complete package automatically"
echo ""
echo "Steps:"
echo "  1. Push your code to GitHub"
echo "  2. Go to: Actions → Build Windows Release"
echo "  3. Click 'Run workflow'"
echo "  4. Download the artifact: 'rustdesk-windows-installer'"
echo "  5. Extract and use!"
echo ""
echo "Your workflow is ready at:"
echo "  .github/workflows/build-windows.yml"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Option 2: Build on Windows Machine${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Requirements:"
echo "  - Windows 10/11 (64-bit)"
echo "  - Visual Studio 2022 (C++ tools)"
echo "  - Rust (from rustup.rs)"
echo "  - Flutter SDK 3.35.6+"
echo "  - Python 3"
echo ""
echo "Build Commands (in PowerShell):"
echo ""
echo "  # Setup vcpkg (one-time)"
echo "  git clone https://github.com/microsoft/vcpkg C:\\vcpkg"
echo "  cd C:\\vcpkg"
echo "  .\\bootstrap-vcpkg.bat"
echo "  .\\vcpkg install libvpx:x64-windows-static libyuv:x64-windows-static opus:x64-windows-static"
echo ""
echo "  # Build RustDesk"
echo "  cd \\path\\to\\rustdesk"
echo "  \$env:VCPKG_ROOT = \"C:\\vcpkg\""
echo "  cargo build --release"
echo "  cd flutter"
echo "  flutter pub get"
echo "  flutter build windows --release"
echo ""
echo "  # Your complete build will be at:"
echo "  # flutter\\build\\windows\\x64\\runner\\Release\\"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Option 3: Use Official Pre-built Binary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Download from:"
echo "  https://github.com/rustdesk/rustdesk/releases"
echo ""
echo "⚠️  Note: Official builds use default servers, not your custom server"
echo ""

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${RED}❌ What DOESN'T Work:${NC}"
echo "  - Single rustdesk.exe file alone"
echo "  - Cross-compiling from Linux (requires Windows)"
echo "  - Running without flutter_windows.dll"
echo "  - Running without data/ folder"
echo ""
echo -e "${GREEN}✅ What DOES Work:${NC}"
echo "  - Complete Release folder from Flutter build"
echo "  - GitHub Actions automated build"
echo "  - Package created by this script"
echo ""

echo -e "${YELLOW}💡 Recommendation:${NC}"
echo "  Use GitHub Actions for the easiest and most reliable build process."
echo ""

