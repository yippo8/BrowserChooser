#!/bin/bash
# BrowserChooser installer
# Compiles the AppleScript app and registers it as a browser

set -e

APP_DIR="$HOME/Applications/BrowserChooser.app"
CONTENTS="$APP_DIR/Contents"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== BrowserChooser Installer ==="
echo ""

# Clean previous install
if [ -d "$APP_DIR" ]; then
    echo "Removing previous installation..."
    rm -rf "$APP_DIR"
fi

# Compile AppleScript into .app bundle
echo "Compiling BrowserChooser.app..."
osacompile -o "$APP_DIR" "$SCRIPT_DIR/BrowserChooser.applescript"

# Replace the Info.plist with our custom one (adds URL scheme + document type handlers)
echo "Configuring as browser..."
cp "$SCRIPT_DIR/Info.plist" "$CONTENTS/Info.plist"

# Register with Launch Services
echo "Registering with macOS..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR"

echo ""
echo "Installed to: $APP_DIR"
echo ""
echo "NEXT STEP: Set BrowserChooser as your default browser:"
echo "  System Settings → Desktop & Dock → Default web browser → BrowserChooser"
echo ""
echo "Done!"
