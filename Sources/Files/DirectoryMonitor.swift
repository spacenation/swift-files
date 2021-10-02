import Foundation

protocol DirectoryMonitorDelegate: AnyObject {
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor {
    weak var delegate: DirectoryMonitorDelegate?
    var monitoredDirectoryFileDescriptor: CInt = -1
    let directoryMonitorQueue =  DispatchQueue(label: "directorymonitor", attributes: .concurrent)
    var directoryMonitorSource: DispatchSource?

    var url: URL

    init(url: URL) {
        self.url = url
    }

    func startMonitoring() {
        // Listen for changes to the directory (if we are not already).
        if directoryMonitorSource == nil && monitoredDirectoryFileDescriptor == -1 {
            // Open the directory referenced by URL for monitoring only.
            monitoredDirectoryFileDescriptor = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)

            // Define a dispatch source monitoring the directory for additions, deletions, and renamings.
            directoryMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredDirectoryFileDescriptor, eventMask: DispatchSource.FileSystemEvent.write, queue: directoryMonitorQueue) as? DispatchSource

            // Define the block to call when a file change is detected.
            directoryMonitorSource?.setEventHandler{
                // Call out to the `DirectoryMonitorDelegate` so that it can react appropriately to the change.
                self.delegate?.directoryMonitorDidObserveChange(directoryMonitor: self)
            }

            // Define a cancel handler to ensure the directory is closed when the source is cancelled.
            directoryMonitorSource?.setCancelHandler{
                close(self.monitoredDirectoryFileDescriptor)
                self.monitoredDirectoryFileDescriptor = -1
                self.directoryMonitorSource = nil
            }

            // Start monitoring the directory via the source.
            directoryMonitorSource?.resume()
        }
    }

    func stopMonitoring() {
        // Stop listening for changes to the directory, if the source has been created.
        if directoryMonitorSource != nil {
            // Stop monitoring the directory via the source.
            directoryMonitorSource?.cancel()
        }
    }
}
