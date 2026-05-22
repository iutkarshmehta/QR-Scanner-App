import Foundation

/// Executes a typed network request and returns a decoded response.
/// Conforming types must be Sendable so they can be held safely on any actor.
protocol APIClient: Sendable {
    func send<T: Decodable>(_ endpoint: some APIEndpoint) async throws -> T
}
