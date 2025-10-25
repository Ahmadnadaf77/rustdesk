#!/bin/bash

# Download Windows Build Script
# This script helps download the Windows build from GitHub Actions

set -e

OUTPUT_DIR="/home/ahmad-nadaf/windesk_new_build_windows"

echo "📥 RustDesk Windows Build Downloader"
echo "===================================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "📋 Install it with:"
    echo "   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "   echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "   sudo apt update"
    echo "   sudo apt install gh"
    echo ""
    echo "🔐 Then authenticate with: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI."
    echo "🔐 Please run: gh auth login"
    exit 1
fi

echo "📁 Output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "🔍 Finding latest Windows build..."

# Get the latest workflow run
LATEST_RUN=$(gh run list --workflow="build-windows.yml" --limit=1 --json databaseId,status,conclusion --jq '.[0]')

if [ "$LATEST_RUN" = "null" ] || [ -z "$LATEST_RUN" ]; then
    echo "❌ No Windows build found. Please run the GitHub Actions workflow first."
    exit 1
fi

RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId')
STATUS=$(echo "$LATEST_RUN" | jq -r '.status')
CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')

echo "📊 Latest run ID: $RUN_ID"
echo "📊 Status: $STATUS"
echo "📊 Conclusion: $CONCLUSION"

if [ "$STATUS" != "completed" ] || [ "$CONCLUSION" != "success" ]; then
    echo "❌ Latest build is not successful. Status: $STATUS, Conclusion: $CONCLUSION"
    echo "🔗 View the run: https://github.com/$(gh repo view --json owner,name --jq '.owner.login + "/" + .name")/actions/runs/$RUN_ID"
    exit 1
fi

echo "✅ Found successful build!"

# Download artifacts
echo "📥 Downloading Windows build artifacts..."
gh run download "$RUN_ID" --dir="/tmp/rustdesk-build"

# Extract to output directory
echo "📦 Extracting to $OUTPUT_DIR..."
if [ -d "/tmp/rustdesk-build/rustdesk-windows-build" ]; then
    cp -r /tmp/rustdesk-build/rustdesk-windows-build/* "$OUTPUT_DIR/"
    echo "✅ Windows build extracted successfully!"
else
    echo "❌ Windows build artifact not found in download."
    exit 1
fi

# Copy build info if available
if [ -f "/tmp/rustdesk-build/build-info/build_info.txt" ]; then
    cp /tmp/rustdesk-build/build-info/build_info.txt "$OUTPUT_DIR/"
    echo "📄 Build info copied."
fi

# Clean up
rm -rf /tmp/rustdesk-build

echo ""
echo "🎉 Windows build ready at: $OUTPUT_DIR"
echo ""
echo "📋 Contents:"
ls -la "$OUTPUT_DIR"

echo ""
echo "🎯 Your custom server configuration:"
echo "   ID Server: 171.22.24.28:21116"
echo "   API Server: https://171.22.24.28"
echo "   Public Key: 8HKCcJSQXbsgojo0gjrTg8uh7Kzfz+NS35lgIbWb0Vw="
echo ""
echo "✅ Download complete!"


