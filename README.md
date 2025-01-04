# Quick Camera

Quick Camera is a macOS utility to display the output from any USB-based camera on your desktop. Quick Camera is often used for presentations where you need to show the output from an external device to your audience. 

Quick Camera supports mirroring (normal and reversed, both vertical and horizontal), can be rotated, resized to any size, and the window can be placed in the foreground.

You can find the app on the Mac App Store: https://itunes.apple.com/us/app/qcamera/id598853070?mt=12

## Building Quick Camera

Quick Camera can be built using XCode. Download XCode from https://developer.apple.com/xcode/ and open the Quick Camera.xcodeproj file.

In addition, with XCode or the XCode Command Line Tools installed, Quick Camera can also be built using the command line:

```bash
xcodebuild -scheme Quick\ Camera -configuration Release clean build
```

Upon successful build, Quick Camera can be launched with:

```bash
open build/release/Quick\ Camera.app
```

Finally, a Package.swift file is included for building Quick Camera using Swift Package Manager. This, however, is designed only to support editing Quick Camera in VS Code (via the Swift Language Support extension and LSP).
