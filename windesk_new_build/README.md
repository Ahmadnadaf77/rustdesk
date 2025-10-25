# WinDesk - Remote Desktop Application

This is a Flutter-based build of WinDesk (formerly RustDesk), a remote desktop application.

## Build Information

- **Application Name**: WinDesk
- **Build Type**: Release
- **Platform**: Linux x64
- **Build Date**: $(date)
- **Flutter Version**: Built with Flutter

## Contents

- `windesk` - Main executable
- `lib/` - Shared libraries and plugins
- `data/` - Application data and assets
- `rustdesk.desktop` - Desktop entry file
- `icon.png` - Application icon
- `logo.png` - Application logo

## Installation

1. Make the executable runnable: `chmod +x windesk`
2. Copy the desktop file to your applications directory:
   ```bash
   cp rustdesk.desktop ~/.local/share/applications/
   ```
3. Update the desktop database:
   ```bash
   update-desktop-database ~/.local/share/applications/
   ```

## Running

You can run the application directly:

```bash
./windesk
```

## Notes

- This is a Flutter frontend build. The full functionality requires the Rust backend components.
- The application has been renamed from RustDesk to WinDesk.
- All configuration files have been updated to reflect the new name.

## Dependencies

The application requires various system libraries that should be available on most Linux distributions:

- GTK3
- Flutter runtime libraries
- Standard system libraries

## Troubleshooting

If you encounter issues:

1. Ensure all required system libraries are installed
2. Check that the executable has proper permissions
3. Verify that the Rust backend components are available if full functionality is needed
