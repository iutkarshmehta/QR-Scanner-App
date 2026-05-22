import Network
import Observation

/// Observes network path changes and publishes connectivity state on @MainActor.
/// Hold a reference in any @Observable ViewModel or read directly from a SwiftUI view.
@Observable
final class NetworkMonitor: @unchecked Sendable {

    static let shared = NetworkMonitor()

    private(set) var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.qrscanner.network.monitor", qos: .utility)

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor [weak self] in
                self?.isConnected = connected
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
