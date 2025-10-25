#!/bin/bash

# RustDesk Windows Release Creator
# This script helps you create a Windows release

echo "🚀 RustDesk Windows Release Creator"
echo "=================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check if we have uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: You have uncommitted changes"
    echo "   Consider committing them before creating a release"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Release creation cancelled"
        exit 1
    fi
fi

# Get version from user
echo
echo "📝 Release Information:"
read -p "Enter version number (e.g., v1.4.4): " VERSION

if [ -z "$VERSION" ]; then
    echo "❌ Error: Version cannot be empty"
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$VERSION$"; then
    echo "❌ Error: Tag $VERSION already exists"
    exit 1
fi

echo
echo "🎯 Creating release: $VERSION"
echo "================================"

# Create and push tag
echo "1️⃣  Creating git tag..."
git tag -a "$VERSION" -m "Release $VERSION - Windows Build"

echo "2️⃣  Pushing tag to remote..."
git push origin "$VERSION"

echo
echo "✅ Release tag created and pushed!"
echo
echo "🔗 What happens next:"
echo "   • GitHub Actions will automatically detect the new tag"
echo "   • The Windows build workflow will start"
echo "   • A release will be created with the Windows installer"
echo "   • You can monitor progress at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\)\.git.*/\1/')/actions"
echo
echo "📦 The release will include:"
echo "   • Windows executable (rustdesk.exe)"
echo "   • All required DLLs and dependencies"
echo "   • Start RustDesk.bat launcher"
echo "   • Installation instructions"
echo
echo "🎉 Your Windows release is being built!"
