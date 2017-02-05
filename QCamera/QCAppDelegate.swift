//
//  AppDelegate.swift
//  Quick Camera
//
//  Created by Simon Guest on 1/22/17.
//  Copyright © 2017 Simon Guest. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

@NSApplicationMain
class QCAppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var selectSourceMenu: NSMenuItem!
    @IBOutlet weak var playerView: AVPlayerView!

    var isMirrored: Bool = false;
    var isUpsideDown: Bool = false;
    var isBorderless: Bool = false;
    var defaultBorderStyle: NSWindowStyleMask = NSWindowStyleMask.closable;
    var windowTitle = "Quick Camera";
    var defaultDeviceIndex: Int = 0;

    var devices: [AVCaptureDevice]!;
    var captureSession: AVCaptureSession!;
    var captureLayer: AVCaptureVideoPreviewLayer!;

    func detectVideoDevices() {
        NSLog("Detecting video devices...");
        self.devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice];

        if (devices?.count == 0) {
            let popup = NSAlert();
            popup.messageText = "Unfortunately, you don't appear to have any cameras connected. Goodbye for now!";
            popup.runModal();
            NSApp.terminate(nil);
        } else {
            NSLog("%d devices found", devices?.count ?? 0);
        }

        let deviceMenu = NSMenu();
        var deviceIndex = 0;

        for device in self.devices {
            let deviceMenuItem = NSMenuItem(title: device.localizedName, action: #selector(deviceMenuChanged), keyEquivalent: "")
            deviceMenuItem.target = self;
            deviceMenuItem.representedObject = deviceIndex;
            if (deviceIndex == defaultDeviceIndex) {
                deviceMenuItem.state = NSOnState;
            }
            if (deviceIndex < 9) {
                deviceMenuItem.keyEquivalent = String(deviceIndex + 1);
            }
            deviceMenu.addItem(deviceMenuItem);
            deviceIndex += 1;
        }
        selectSourceMenu.submenu = deviceMenu;
    }

    func startCaptureWithVideoDevice(defaultDevice: Int) {
        NSLog("Starting capture with device index %d", defaultDevice);
        if (captureSession != nil) {
            captureSession.stopRunning();
        }
        captureSession = AVCaptureSession();
        let device: AVCaptureDevice = self.devices[defaultDevice];
        do {
            let input: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device);
            self.captureSession.addInput(input);
            self.captureSession.startRunning();
            self.captureLayer = AVCaptureVideoPreviewLayer(session: self.captureSession);
            self.captureLayer.connection.automaticallyAdjustsVideoMirroring = false;
            self.captureLayer.connection.isVideoMirrored = false;
            self.playerView.layer = self.captureLayer;
            self.playerView.controlsStyle = AVPlayerViewControlsStyle.none;
            self.playerView.layer?.backgroundColor = CGColor.black;
            self.windowTitle = String(format: "Quick Camera: [%@]", device.localizedName);
            self.window.title = self.windowTitle;
        } catch {
            NSLog("Error while opening device");
            let popup = NSAlert();
            popup.messageText = "Unfortunately, there was an error when trying to access the camera. Try again or select a different one.";
            popup.runModal();
        }
    }

    @IBAction func mirrorImageSelected(_ sender: NSMenuItem) {
        NSLog("Mirror image menu item selected");
        isMirrored = !isMirrored;
        self.captureLayer.connection.isVideoMirrored = isMirrored;
        sender.state = (isMirrored ? NSOnState : NSOffState);
    }

    @IBAction func mirrorVerticalImageSelected(_ sender: NSMenuItem) {
        NSLog("Mirror image vertically menu item selected");
        isUpsideDown = !isUpsideDown;
        self.captureLayer.connection.videoOrientation = isUpsideDown ? AVCaptureVideoOrientation.portraitUpsideDown : AVCaptureVideoOrientation.portrait;
        sender.state = (isUpsideDown ? NSOnState : NSOffState);
    }


    @IBAction func borderlessSelected(_ sender: NSMenuItem) {
        NSLog("Borderless menu item selected");
        isBorderless = !isBorderless;
        sender.state = (isBorderless ? NSOnState : NSOffState);

        if (isBorderless) {
            // remove border and affix window on top
            defaultBorderStyle = window.styleMask;
            self.window.styleMask = NSWindowStyleMask.borderless;
            self.window.level = Int(CGWindowLevelForKey(.maximumWindow));
            window.isMovableByWindowBackground = true;
        } else {
            window.styleMask = defaultBorderStyle;
            window.title = self.windowTitle;
            self.window.level = Int(CGWindowLevelForKey(.normalWindow));
            window.isMovableByWindowBackground = false;
        }
    }

    func deviceMenuChanged(_ sender: NSMenuItem) {
        NSLog("Device Menu changed");
        if (sender.state == NSOnState) {
            // selected the active device, so nothing to do here
            return;
        }

        // set the checkbox on the currently selected device
        for menuItem: NSMenuItem in selectSourceMenu.submenu!.items {
            menuItem.state = NSOffState;
        }
        sender.state = NSOnState;

        self.startCaptureWithVideoDevice(defaultDevice: sender.representedObject as! Int)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        detectVideoDevices();
        startCaptureWithVideoDevice(defaultDevice: defaultDeviceIndex);
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }

}
