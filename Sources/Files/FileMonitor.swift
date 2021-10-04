import Foundation
import Combine

public final class FileMonitor: ObservableObject {
    @Published public var data: Data
    public let url: URL
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(url: URL) {
        self.url = url
        data = try! Data(contentsOf: url)
        
        $data
            .debounce(for: .milliseconds(2000), scheduler: RunLoop.main)
            .sink {
                try! $0.write(to: url)
            }
            .store(in: &cancellables)
    }
}
