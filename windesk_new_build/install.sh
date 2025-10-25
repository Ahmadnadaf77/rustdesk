#!/bin/bash

# WinDesk Installation Script
echo "Installing WinDesk..."

# Make executable
chmod +x windesk

# Create application directory
mkdir -p ~/.local/share/applications/

# Copy desktop file
cp rustdesk.desktop ~/.local/share/applications/windesk.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo "WinDesk has been installed!"
echo "You can now find it in your applications menu or run it with: ./windesk"
