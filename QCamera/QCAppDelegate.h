//
//  QCAppDelegate.h
//  QCamera
//
//  Created by Simon Guest on 1/29/13.
//  Copyright (c) 2013 Simon Guest. All rights reserved.
//

#import <QTKit/QTKit.h>
#import <Cocoa/Cocoa.h>

@interface QCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet QTCaptureView *mCaptureView;
@property (strong) QTCaptureSession *mCaptureSession;
@property (strong) QTCaptureDeviceInput *mCaptureDeviceInput;
@property (strong) NSArray *allVideoDevices;

@property (strong) IBOutlet NSMenuItem *mSelectSourceMenu;
- (IBAction)menuChanged:(id)sender;

@property (strong) NSMenu *mSelectSourceSubMenu;

@property (strong) IBOutlet NSMenuItem *mMirrorImageMenu;
- (IBAction)mMirrorImageMenuSelected:(id)sender;

@property (strong) IBOutlet NSMenuItem *mHideBorderMenu;
- (IBAction)mHideBorderMenuSelected:(id)sender;


- (void)startCaptureWithVideoDeviceIndex:(int)videoDeviceIndex;

@end
