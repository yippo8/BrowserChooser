#!/bin/bash
# BrowserChooser uninstaller

set -e

APP_DIR="$HOME/Applications/BrowserChooser.app"

echo "=== BrowserChooser Uninstaller ==="
echo ""

if [ ! -d "$APP_DIR" ]; then
    echo "BrowserChooser is not installed."
    exit 0
fi

# Unregister from Launch Services
echo "Unregistering from macOS..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "$APP_DIR" 2>/dev/null || true

# Remove app
echo "Removing $APP_DIR..."
rm -rf "$APP_DIR"

echo ""
echo "BrowserChooser has been uninstalled."
echo "Remember to set a new default browser in:"
echo "  System Settings → Desktop & Dock → Default web browser"
echo ""
echo "Done!"
