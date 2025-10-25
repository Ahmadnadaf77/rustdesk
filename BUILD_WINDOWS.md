# Windows Build Instructions

## Prerequisites

1. **Windows 10/11** machine
2. **Visual Studio 2022** with C++ build tools
3. **Rust toolchain** (stable)
4. **Flutter SDK** (3.35.6 or later)

## Setup Steps

### 1. Install Visual Studio 2022

- Download from: https://visualstudio.microsoft.com/downloads/
- Install with "Desktop development with C++" workload
- Include Windows 10/11 SDK

### 2. Install Rust

```powershell
# Download and run rustup-init.exe from https://rustup.rs/
# Or use chocolatey:
choco install rust
```

### 3. Install Flutter

```powershell
# Download from https://flutter.dev/docs/get-started/install/windows
# Add to PATH: C:\flutter\bin
flutter doctor
```

### 4. Build Commands

```powershell
# Clone/copy the project
cd rustdesk

# Install Flutter dependencies
cd flutter
flutter pub get

# Build Rust backend
cd ..
cargo build --release

# Build Windows Flutter app
cd flutter
flutter build windows --release
```

## Output Location

The Windows build will be in:

```
flutter/build/windows/x64/runner/Release/
```

## Custom Server Configuration

Your custom server settings are already configured:

- ID Server: 171.22.24.28:21116
- API Server: https://171.22.24.28
- Public Key: 8HKCcJSQXbsgojo0gjrTg8uh7Kzfz+NS35lgIbWb0Vw=

No additional configuration needed - the build will automatically use your custom server.
