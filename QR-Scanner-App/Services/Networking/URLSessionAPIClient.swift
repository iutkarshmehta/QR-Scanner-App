import Foundation

final class URLSessionAPIClient: APIClient, @unchecked Sendable {

    static let shared = URLSessionAPIClient()

    private let session: URLSession

    init(timeoutInterval: TimeInterval = 12) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)
    }

    nonisolated func send<T: Decodable>(_ endpoint: some APIEndpoint) async throws -> T {
        let request: URLRequest
        do {
            request = try endpoint.urlRequest()
        } catch {
            throw APIError.malformedEndpoint
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .dataNotAllowed,
                 .internationalRoamingOff:
                throw APIError.noConnectivity
            default:
                throw APIError.transportFailed(urlError)
            }
        } catch {
            throw APIError.transportFailed(error)
        }

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw APIError.httpError(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
