# BrowserChooser

A lightweight macOS app that prompts you to choose a browser every time you open a link. Built for people who use both Chrome and Microsoft Edge (via Parallels) and want to pick which one to use on a per-link basis.

![macOS](https://img.shields.io/badge/macOS-12%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## How It Works

1. Set BrowserChooser as your default browser
2. Click any link (from Mail, Slack, Obsidian, anywhere)
3. A dialog pops up asking: **Chrome** or **Edge**?
4. The link opens in your chosen browser

That's it. No menubar icon, no background process, no config files.

## Installation

```bash
git clone https://github.com/brandonyip/BrowserChooser.git
cd BrowserChooser
./install.sh
```

Then set it as your default browser:
**System Settings → Desktop & Dock → Default web browser → BrowserChooser**

## Uninstall

```bash
./uninstall.sh
```

## Customization

The app is a single AppleScript file (`BrowserChooser.applescript`). You can easily customize it:

### Change browsers

Edit the browser paths in `BrowserChooser.applescript`:

```applescript
-- Chrome (default macOS path)
do shell script "open -a '/Applications/Google Chrome.app' " & quoted form of theURL

-- Edge via Parallels (update the VM ID to match yours)
set edgePath to (POSIX path of (path to home folder)) & "Applications (Parallels)/{YOUR-VM-ID} Applications.localized/Microsoft Edge.app"
```

### Find your Parallels VM ID

```bash
ls ~/Applications\ \(Parallels\)/
```

The folder name starting with `{` contains your VM ID.

### Add more browsers

Add another button and condition:

```applescript
buttons {"Cancel", "Firefox (F)", "Edge (E)", "Chrome (C)"}
```

Note: macOS dialogs support up to 3 buttons. For more browsers, you can use `choose from list` instead.

## How It Registers as a Browser

macOS requires specific `Info.plist` entries for an app to appear in the default browser picker:

- `CFBundleURLTypes` — declares `http` and `https` URL scheme handling
- `CFBundleDocumentTypes` — declares support for `public.html`, `public.xhtml`, and `public.url` content types
- `NSPrincipalClass` — set to `NSApplication`

The install script compiles the AppleScript, replaces the `Info.plist`, and registers with Launch Services.

## Requirements

- macOS 12+
- At least one of the target browsers installed
- For Edge via Parallels: Parallels Desktop with a Windows VM that has Edge

## License

MIT
