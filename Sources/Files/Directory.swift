import Foundation
@_exported import Tree

final public class Directory: ObservableObject, DirectoryMonitorDelegate {
    @Published public internal(set) var files: [NonEmptyTree<URL>] = []
    var directoryMonitor: DirectoryMonitor?
    
    public init() {
    }
    
    public func addTree(url: URL) {
        self.files.append(url.tree)
        self.directoryMonitor = DirectoryMonitor(url: url)
        self.directoryMonitor?.delegate = self
        self.directoryMonitor?.startMonitoring()
    }
    
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        DispatchQueue.main.async {
            print("Update")
            self.files[0] = directoryMonitor.url.tree
        }
    }
}

extension FileManager {
    func urls(for directoryUrl: URL, skipsHiddenFiles: Bool = true) -> [URL]? {
        let fileURLs = try? contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

extension URL {
    var tree: NonEmptyTree<URL> {
        if self.hasDirectoryPath {
            if let urls = FileManager.default.urls(for: self), !urls.isEmpty {
                return .node(self,
                        .init(
                            head: urls[0].tree,
                            tail: List(Array(urls.dropFirst()).map({ $0.tree }))
                        )
                    )
            } else {
                return .leaf(self)
            }
        } else {
            return .leaf(self)
        }
    }
}

