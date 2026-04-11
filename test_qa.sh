#!/bin/bash
# QA/QC test suite for BrowserChooser
# Tests the install process, plist integrity, and URL handling

set -e

PASS=0
FAIL=0
TOTAL=0

APP_DIR="$HOME/Applications/BrowserChooser.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

pass() {
    PASS=$((PASS + 1))
    TOTAL=$((TOTAL + 1))
    echo "  PASS: $1"
}

fail() {
    FAIL=$((FAIL + 1))
    TOTAL=$((TOTAL + 1))
    echo "  FAIL: $1"
}

echo "=== BrowserChooser QA/QC Test Suite ==="
echo ""

# --- Round 1: Source file integrity ---
echo "Round 1: Source file integrity"
[ -f "$SCRIPT_DIR/BrowserChooser.applescript" ] && pass "AppleScript source exists" || fail "AppleScript source missing"
[ -f "$SCRIPT_DIR/Info.plist" ] && pass "Info.plist source exists" || fail "Info.plist source missing"
[ -f "$SCRIPT_DIR/install.sh" ] && pass "install.sh exists" || fail "install.sh missing"
[ -f "$SCRIPT_DIR/uninstall.sh" ] && pass "uninstall.sh exists" || fail "uninstall.sh missing"
[ -x "$SCRIPT_DIR/install.sh" ] && pass "install.sh is executable" || fail "install.sh not executable"
[ -x "$SCRIPT_DIR/uninstall.sh" ] && pass "uninstall.sh is executable" || fail "uninstall.sh not executable"
echo ""

# --- Round 2: AppleScript syntax validation ---
echo "Round 2: AppleScript syntax validation"
if osacompile -o /tmp/_bc_test_compile.app "$SCRIPT_DIR/BrowserChooser.applescript" 2>/dev/null; then
    pass "AppleScript compiles without errors"
    rm -rf /tmp/_bc_test_compile.app
else
    fail "AppleScript has compilation errors"
fi
echo ""

# --- Round 3: Info.plist XML validity ---
echo "Round 3: Info.plist XML validation"
if plutil -lint "$SCRIPT_DIR/Info.plist" >/dev/null 2>&1; then
    pass "Info.plist is valid XML plist"
else
    fail "Info.plist has XML errors"
fi
echo ""

# --- Round 4: Info.plist required keys ---
echo "Round 4: Info.plist required browser keys"
PLIST="$SCRIPT_DIR/Info.plist"
if /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST" >/dev/null 2>&1; then
    pass "CFBundleIdentifier present"
else
    fail "CFBundleIdentifier missing"
fi
if /usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes" "$PLIST" >/dev/null 2>&1; then
    pass "CFBundleURLTypes present"
else
    fail "CFBundleURLTypes missing"
fi
if /usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes" "$PLIST" >/dev/null 2>&1; then
    pass "CFBundleDocumentTypes present"
else
    fail "CFBundleDocumentTypes missing"
fi
if /usr/libexec/PlistBuddy -c "Print :NSPrincipalClass" "$PLIST" >/dev/null 2>&1; then
    pass "NSPrincipalClass present"
else
    fail "NSPrincipalClass missing"
fi
echo ""

# --- Round 5: URL scheme declarations ---
echo "Round 5: URL scheme coverage"
HTTP_SCHEME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes:0:CFBundleURLSchemes:0" "$PLIST" 2>/dev/null)
HTTPS_SCHEME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes:1:CFBundleURLSchemes:0" "$PLIST" 2>/dev/null)
[ "$HTTP_SCHEME" = "http" ] && pass "HTTP scheme registered" || fail "HTTP scheme missing (got: $HTTP_SCHEME)"
[ "$HTTPS_SCHEME" = "https" ] && pass "HTTPS scheme registered" || fail "HTTPS scheme missing (got: $HTTPS_SCHEME)"
echo ""

# --- Round 6: Document type declarations ---
echo "Round 6: Document type content types"
CT0=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes:0:LSItemContentTypes:0" "$PLIST" 2>/dev/null)
CT1=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes:0:LSItemContentTypes:1" "$PLIST" 2>/dev/null)
CT2=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes:0:LSItemContentTypes:2" "$PLIST" 2>/dev/null)
[ "$CT0" = "public.html" ] && pass "public.html content type" || fail "public.html missing"
[ "$CT1" = "public.xhtml" ] && pass "public.xhtml content type" || fail "public.xhtml missing"
[ "$CT2" = "public.url" ] && pass "public.url content type" || fail "public.url missing"
echo ""

# --- Round 7: Installed app validation ---
echo "Round 7: Installed app bundle"
if [ -d "$APP_DIR" ]; then
    pass "App bundle exists at $APP_DIR"
    [ -d "$APP_DIR/Contents/MacOS" ] && pass "MacOS directory present" || fail "MacOS directory missing"
    [ -d "$APP_DIR/Contents/Resources" ] && pass "Resources directory present" || fail "Resources directory missing"
    [ -f "$APP_DIR/Contents/Info.plist" ] && pass "Installed Info.plist present" || fail "Installed Info.plist missing"
else
    fail "App not installed at $APP_DIR (run install.sh first)"
fi
echo ""

# --- Round 8: Installed plist matches source ---
echo "Round 8: Installed plist integrity"
if [ -f "$APP_DIR/Contents/Info.plist" ]; then
    INSTALLED_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_DIR/Contents/Info.plist" 2>/dev/null)
    SOURCE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST" 2>/dev/null)
    [ "$INSTALLED_ID" = "$SOURCE_ID" ] && pass "Bundle ID matches source" || fail "Bundle ID mismatch: installed=$INSTALLED_ID source=$SOURCE_ID"

    INSTALLED_URLS=$(/usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes" "$APP_DIR/Contents/Info.plist" 2>/dev/null)
    [ -n "$INSTALLED_URLS" ] && pass "Installed plist has URL types" || fail "Installed plist missing URL types"

    INSTALLED_DOCS=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes" "$APP_DIR/Contents/Info.plist" 2>/dev/null)
    [ -n "$INSTALLED_DOCS" ] && pass "Installed plist has document types" || fail "Installed plist missing document types"
else
    fail "Skipped - app not installed"
fi
echo ""

# --- Round 9: Launch Services registration ---
echo "Round 9: Launch Services registration"
LS_DUMP=$(/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump 2>/dev/null)
if echo "$LS_DUMP" | grep -q "com.browserchooser.app" 2>/dev/null; then
    pass "App registered in Launch Services"
else
    # Try the other bundle ID
    if echo "$LS_DUMP" | grep -q "com.brandonyip.browserchooser" 2>/dev/null; then
        pass "App registered in Launch Services (brandonyip ID)"
    else
        fail "App not found in Launch Services"
    fi
fi
echo ""

# --- Round 10: AppleScript content validation ---
echo "Round 10: AppleScript logic validation"
SCRIPT_CONTENT=$(cat "$SCRIPT_DIR/BrowserChooser.applescript")
echo "$SCRIPT_CONTENT" | grep -q "open location" && pass "Has 'open location' handler" || fail "Missing 'open location' handler"
echo "$SCRIPT_CONTENT" | grep -q "on run" && pass "Has 'on run' handler" || fail "Missing 'on run' handler"
echo "$SCRIPT_CONTENT" | grep -q "Chrome" && pass "Chrome option present" || fail "Chrome option missing"
echo "$SCRIPT_CONTENT" | grep -q "Edge" && pass "Edge option present" || fail "Edge option missing"
echo "$SCRIPT_CONTENT" | grep -q "Cancel" && pass "Cancel option present" || fail "Cancel option missing"
echo "$SCRIPT_CONTENT" | grep -q "quoted form of theURL" && pass "URL is shell-escaped (quoted form)" || fail "URL not shell-escaped — injection risk"
echo "$SCRIPT_CONTENT" | grep -q "giving up after" && pass "Dialog has timeout (won't hang)" || fail "Dialog has no timeout"
echo "$SCRIPT_CONTENT" | grep -q "display dialog" && pass "Uses display dialog for prompt" || fail "Missing display dialog"
echo ""

# --- Summary ---
echo "==========================="
echo "Results: $PASS passed, $FAIL failed, $TOTAL total"
echo "==========================="

if [ $FAIL -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed. Review above."
    exit 1
fi
