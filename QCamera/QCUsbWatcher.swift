//
//  QCUsbWatcher.swift
//  Quick Camera
//
//  Created by Ross Beazley on 07/08/2020.
//  Copyright © 2020 Simon Guest. All rights reserved.
//
import IOKit
import IOKit.usb
import IOKit.usb.IOUSBLib
public protocol QCUsbWatcherDelegate: AnyObject {
    func deviceCountChanged()
}

public class QCUsbWatcher {
    public weak var delegate: QCUsbWatcherDelegate?
    private let notificationPort = IONotificationPortCreate(kIOMasterPortDefault)
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0
    
    public init() {
        func handleNotification(instance: UnsafeMutableRawPointer?, _ iterator: io_iterator_t) {
            let watcher = Unmanaged<QCUsbWatcher>.fromOpaque(instance!).takeUnretainedValue()
            while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
                
                //give the OS a bit of time to finish setting up capture devices
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    watcher.delegate?.deviceCountChanged()
                }
                IOObjectRelease(device)
            }
        }
    
        let query = IOServiceMatching(kIOUSBDeviceClassName)
        let opaqueSelf = Unmanaged.passUnretained(self).toOpaque()
        
        // Watch for connected devices.
        IOServiceAddMatchingNotification(
            notificationPort, kIOMatchedNotification, query,
            handleNotification, opaqueSelf, &addedIterator)
        consumeInitialUSBEvents(addedIterator)

        // Watch for disconnected devices.
        IOServiceAddMatchingNotification(
            notificationPort, kIOTerminatedNotification, query,
            handleNotification, opaqueSelf, &removedIterator)
        consumeInitialUSBEvents(removedIterator)
        
        // Add the notification to the main run loop to receive future updates.
        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue(),
            .commonModes)
    }

    deinit {
        IOObjectRelease(addedIterator)
        IOObjectRelease(removedIterator)
        IONotificationPortDestroy(notificationPort)
    }
    
    fileprivate func consumeInitialUSBEvents(_ iterator: io_iterator_t) {
        while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
            IOObjectRelease(device)
        }
    }
}


