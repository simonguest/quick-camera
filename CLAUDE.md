# Quick Camera - Project Context for AI Assistants

## Project Overview

Quick Camera is a macOS utility application that displays output from USB-based cameras on the desktop. It's primarily used for presentations where users need to show external device output to an audience. The app is available on the Mac App Store.

**Key Features:**
- Display any USB camera feed in a resizable window
- Mirror (horizontal and vertical flip)
- Rotate in 90° increments
- Borderless mode with always-on-top
- Aspect ratio locking
- Capture and save snapshots as PNG
- Hot-plug USB camera detection
- Persistent window position and settings

## Technical Stack

- **Platform**: macOS 12+ (Monterey and later)
- **Language**: Swift
- **UI Framework**: AppKit (traditional NSApplication, not SwiftUI)
- **Build System**: Xcode project with SPM support for editing
- **Key Frameworks**:
  - AVFoundation (camera capture)
  - AVKit (video preview)
  - IOKit (USB device monitoring)
  - Cocoa/AppKit (UI)

## Architecture

### File Structure

The project has a simple, focused architecture with just 3 main Swift files:

1. **QCAppDelegate.swift** (486 lines)
   - Main application controller
   - Manages camera capture sessions
   - Handles all UI interactions via IBOutlets and IBActions
   - Coordinates settings and USB monitoring

2. **QCSettingsManager.swift** (113 lines)
   - Singleton pattern for settings management
   - Persists user preferences via UserDefaults
   - Manages: device selection, mirror states, rotation, window frame, borderless mode

3. **QCUsbWatcher.swift** (69 lines)
   - Monitors USB device connection/disconnection events
   - Uses IOKit for low-level hardware notifications
   - Delegate pattern to notify app when devices change

### Key Design Patterns

- **Singleton**: `QCSettingsManager.shared` for centralized settings
- **Delegate**: `QCUsbWatcherDelegate` for USB event notifications
- **Interface Builder**: XIB/Storyboard with `@IBOutlet` and `@IBAction`
- **MVC**: Traditional Model-View-Controller architecture

## Important Implementation Details

### Camera Management

- Uses `AVCaptureDevice.DiscoverySession` to enumerate devices
- Supports both `.builtInWideAngleCamera` and `.externalUnknown` device types
- Device menu dynamically updates when USB devices are connected/disconnected
- Keyboard shortcuts 1-9 for quick camera switching
- Prevents unnecessary session restarts when selecting the already-active device

### Display Transformations

- **Rotation**: 4 positions (0-3) representing 0°, 90°, 180°, 270°
- **Position 0**: Portrait, Position 1: Landscape Left, Position 2: Portrait Upside Down, Position 3: Landscape Right
- Rotation interacts with vertical flip (upside down) setting
- Window dimensions swap when rotating 90°/270°

### Window Behavior

- **Borderless mode**: Removes title bar, makes window always-on-top (maximum window level), enables drag-by-background
- **Aspect ratio**: Can be locked to match camera's native resolution
- **Full screen**: Standard macOS full screen support
- **Frame persistence**: Window position and size saved to UserDefaults

### Image Capture

- Uses `CGWindowListCreateImage` to capture window contents
- Temporarily removes border (if present) for clean capture
- 0.1 second RunLoop pause to allow window repaint before capture
- Saves as PNG with timestamp in filename format: "Quick Camera Image YYYY-MM-DD at h.mm.ss a.png"

### USB Monitoring

- IOKit integration watches for `kIOUSBDeviceClassName` notifications
- 0.5 second delay after detection to allow macOS to set up capture devices
- Properly manages IOKit objects and notification port lifecycle

## Code Style & Conventions

- Uses `// MARK: -` comments extensively to organize code sections
- Properties use computed properties with getters/setters that delegate to `QCSettingsManager`
- Comprehensive NSLog statements for debugging
- Error handling via NSAlert modal dialogs
- Availability checks for macOS version-specific features (e.g., `@available(OSX 10.15, *)`)

## Build & Distribution

- Primary build: Xcode with Quick Camera.xcodeproj
- Command line: `xcodebuild -scheme Quick\ Camera -configuration Release clean build`
- SPM: Package.swift included for editing support in VS Code (not for primary builds)
- App Store distribution via Mac App Store

## Known Considerations

1. **Interface Builder**: UI is defined in XIB/Storyboard files (not included in SPM Package.swift)
2. **macOS 10.12+**: Image saving requires Sierra or later
3. **macOS 10.15+**: Some format descriptor APIs require Catalina
4. **RunLoop hack**: 0.1 second pause before screenshot capture - maintainer notes this isn't ideal

## Common Tasks

### Adding a new setting
1. Add property to `QCSettingsManager`
2. Add setter method
3. Add to `loadSettings()`, `saveSettings()`, and `logSettings()`
4. Add computed property in `QCAppDelegate` if needed
5. Update `applySettings()` if it affects display

### Adding a new transformation
1. Add IBAction in `QCAppDelegate`
2. Update `applySettings()` method
3. Consider interactions with rotation position and mirror states
4. Add menu item in XIB/Storyboard

### Debugging camera issues
- Check NSLog output for device detection
- Verify device appears in `AVCaptureDevice.DiscoverySession`
- USB watcher triggers `deviceCountChanged()` on hot-plug events
- Session restart logic in `startCaptureWithVideoDevice()`

## Future AI Assistant Notes

- This is an **AppKit** app, not SwiftUI - avoid suggesting SwiftUI solutions
- The app uses traditional MVC with Interface Builder - XIB/Storyboard files exist but aren't in SPM manifest
- Settings persistence is via UserDefaults, not SwiftData or Core Data
- Camera capture uses AVFoundation's `AVCaptureSession`, not newer APIs
- Keep the simple, focused architecture - this is intentionally a lightweight utility

---

*Last updated: May 8, 2026*
