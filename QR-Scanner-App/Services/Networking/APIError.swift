import Foundation

enum APIError: LocalizedError {
    case malformedEndpoint
    case noConnectivity
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case transportFailed(Error)

    var errorDescription: String? {
        switch self {
        case .malformedEndpoint:
            return "Invalid QR code — cannot form a request URL."
        case .noConnectivity:
            return "You appear to be offline. Please check your connection and try again."
        case .httpError(let code):
            switch code {
            case 400...499: return "The request could not be completed. Please try again."
            case 500...599: return "The verification service is temporarily unavailable. Please try again shortly."
            default:        return "Something went wrong. Please try again."
            }
        case .decodingFailed:
            return "Unable to parse the product response."
        case .transportFailed(let error):
            return error.localizedDescription
        }
    }
}
