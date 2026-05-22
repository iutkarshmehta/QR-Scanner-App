import Foundation

/// Describes a single HTTP endpoint. Conforming types supply only what makes
/// them unique; everything else falls back to sensible defaults.
protocol APIEndpoint {
    nonisolated var scheme: String { get }
    nonisolated var host: String { get }
    nonisolated var path: String { get }
    nonisolated var method: HTTPMethod { get }
    nonisolated var queryItems: [URLQueryItem]?   { get }
    nonisolated var headers: [String: String]? { get }
    nonisolated var body: Data?             { get }
}

extension APIEndpoint {
    nonisolated var scheme: String { "https" }
    nonisolated var queryItems: [URLQueryItem]?   { nil }
    nonisolated var headers: [String: String]? { nil }
    nonisolated var body: Data?             { nil }

    nonisolated func urlRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.malformedEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}
