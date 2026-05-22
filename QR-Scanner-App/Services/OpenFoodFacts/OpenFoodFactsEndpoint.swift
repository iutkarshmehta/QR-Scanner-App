import Foundation

enum OpenFoodFactsEndpoint: APIEndpoint {
    case product(barcode: String)

    nonisolated var host: String { "world.openfoodfacts.org" }

    nonisolated var path: String {
        switch self {
        case .product(let barcode):
            return "/api/v0/product/\(barcode).json"
        }
    }

    nonisolated var method: HTTPMethod { .get }
}
