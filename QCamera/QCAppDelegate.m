//
//  QCAppDelegate.m
//  QCamera
//
//  Created by Simon Guest on 1/29/13.
//  Copyright (c) 2013 Simon Guest. All rights reserved.
//

#import "QCAppDelegate.h"
#import <QTKit/QTKit.h>

@implementation QCAppDelegate

BOOL isMirrored = FALSE;
BOOL isBorderless = FALSE;
NSUInteger defaultBorderStyle;
NSString *currentWindowTitle;
int defaultDeviceIndex = 0;

- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image
{
    if (isMirrored)
    {
        // apply transform to invert the image
        return [image imageByApplyingTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
    }
    else{
        return image;
    }
}

- (void)detectVideoDevices{
    // enumerate through the video devices and add them to the menu
    _allVideoDevices = [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo];
    
    // Check whether there are zero valid devices and abort if necessary
    if ([_allVideoDevices count] == 0)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Unfortunately, you don't appear to have any cameras connected.  Goodbye for now!"];
        [alert runModal];
        [NSApp terminate:nil];
    }
    
    // Create the source select menu
    _mSelectSourceSubMenu = [[NSMenu alloc] init];
    
    // Build the source select menu
    for (id device in _allVideoDevices)
    {
        int deviceIndex = (int)[_allVideoDevices indexOfObject:device];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[device localizedDisplayName] action:@selector(menuChanged:) keyEquivalent:@""];
        [item setTarget:self];
        [item setRepresentedObject:[NSNumber numberWithInteger:deviceIndex]];
        // is this the default device to start with?
        if (deviceIndex == defaultDeviceIndex)
        {
            [item setState:NSOnState];
        }
        // shall we add a shortcut key?
        if (deviceIndex < 9)
        {
            [item setKeyEquivalent:[NSString stringWithFormat:@"%i", deviceIndex + 1]];
        }
        [_mSelectSourceSubMenu addItem:item];
    }
    
    // Add the sub menu
    [_mSelectSourceMenu setSubmenu:_mSelectSourceSubMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Starting application...");
    // Let's see what we have...
    [self detectVideoDevices];
    
    // Start camera capture with the default device
    [self startCaptureWithVideoDeviceIndex:defaultDeviceIndex];
}

- (void)startCaptureWithVideoDeviceIndex:(int)videoDeviceIndex
{
    NSLog(@"Switching input to video device %i",videoDeviceIndex);
    BOOL success = NO;
    NSError *error;
    if (_mCaptureSession) [_mCaptureSession stopRunning];
    _mCaptureSession = [[QTCaptureSession alloc]init];
    
    QTCaptureDevice *device = (QTCaptureDevice*) [_allVideoDevices objectAtIndex:videoDeviceIndex];
    if (device) {
        success = [device open:&error];
        if (!success)
        {
            NSLog(@"Could not open device.");
            // A USB device may have been removed - let's update the list
            [self detectVideoDevices];
            return;
            
        }
        _mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
        success = [_mCaptureSession addInput:_mCaptureDeviceInput error:&error];
        if (!success) {
            // Handle error
            NSLog(@"Could not start capture session");
            [self detectVideoDevices];
            return;
        }
        
        // set delegate to implement any effects
        [_mCaptureView setDelegate:self];
        // start the capture session
        [_mCaptureView setCaptureSession:_mCaptureSession];
        [_mCaptureSession startRunning];
        
        // update the title of the window
        currentWindowTitle = [NSString stringWithFormat:@"QCamera - [%@]",[device localizedDisplayName]];
        [_window setTitle:currentWindowTitle];
    }
}

- (IBAction)mMirrorImageMenuSelected:(id)sender {
    NSLog(@"Mirror image menu item selected");
    // Set mirrored state correctly
    [sender setState:!isMirrored];
    isMirrored = ([sender state] == NSOnState);
}

- (IBAction)mHideBorderMenuSelected:(id)sender {
    NSLog(@"Hide border menu item selected");
    // Set border state correctly
    [sender setState:!isBorderless];
    isBorderless = ([sender state] == NSOnState);
    
    if (isBorderless)
    {
        // Get rid of the border and keep the window on top
        defaultBorderStyle = [_window styleMask];
        [_window setStyleMask:NSBorderlessWindowMask];
        [_window setLevel:NSFloatingWindowLevel];
    }
    else
    {
        // Put the original border and title back
        [_window setStyleMask:defaultBorderStyle];
        [_window setTitle:currentWindowTitle];
        [_window setLevel:NSNormalWindowLevel];
    }
}

- (IBAction)menuChanged:(id)sender {
    
    NSLog(@"Menu switched to request device index: %@",(NSNumber*)[sender representedObject]);
    
    // Check whether we are already capturing this device index, and ignore request...
    if ([sender state] == NSOnState) return;
    
    // clear the checkboxes on the existing submenus
    for(id menuItem in [_mSelectSourceSubMenu itemArray])
    {
        [menuItem setState:NSOffState];
    }
    
    // mark the submenu item as checked
    [sender setState:NSOnState];
    
    // start the capture using this new device
    [self startCaptureWithVideoDeviceIndex:[(NSNumber*)[sender representedObject] intValue]];
}

// Ensure that the utility quits if the user closes the camera window
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}
@end