import IOKit
import IOKit.usb
import IOKit.usb.IOUSBLib

// MARK: - Protocol
public protocol QCUsbWatcherDelegate: AnyObject {
    func deviceCountChanged()
}

// MARK: - QCUsbWatcher Class
public class QCUsbWatcher {
    // MARK: - Properties
    public weak var delegate: QCUsbWatcherDelegate?
    private let notificationPort: IONotificationPortRef? = IONotificationPortCreate(
        kIOMainPortDefault)
    private var addedIterator: io_iterator_t = 0
    private var removedIterator: io_iterator_t = 0

    // MARK: - Initialization
    public init() {
        func handleNotification(instance: UnsafeMutableRawPointer?, _ iterator: io_iterator_t) {
            let watcher: QCUsbWatcher = Unmanaged<QCUsbWatcher>.fromOpaque(instance!)
                .takeUnretainedValue()
            while case let device:io_object_t = IOIteratorNext(iterator), device != IO_OBJECT_NULL {

                //give the OS a bit of time to finish setting up capture devices
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    watcher.delegate?.deviceCountChanged()
                }
                IOObjectRelease(device)
            }
        }

        let query: CFMutableDictionary? = IOServiceMatching(kIOUSBDeviceClassName)
        let opaqueSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()

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

    // MARK: - Deinitialization
    deinit {
        IOObjectRelease(addedIterator)
        IOObjectRelease(removedIterator)
        IONotificationPortDestroy(notificationPort)
    }

    // MARK: - Private Methods
    fileprivate func consumeInitialUSBEvents(_ iterator: io_iterator_t) {
        while case let device:io_object_t = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
            IOObjectRelease(device)
        }
    }
}
