import Foundation

/// Domain-level abstraction over product lookups.
/// ViewModels depend on this protocol, not on any concrete HTTP client.
protocol ProductRepository: Sendable {
    func fetchProduct(barcode: String) async throws -> ProductDetails
}

final class OpenFoodFactsRepository: ProductRepository, @unchecked Sendable {

    static let shared = OpenFoodFactsRepository()

    private let client: any APIClient

    init(client: any APIClient = URLSessionAPIClient.shared) {
        self.client = client
    }

    nonisolated func fetchProduct(barcode: String) async throws -> ProductDetails {
        let response: OpenFoodFactsResponse = try await client.send(
            OpenFoodFactsEndpoint.product(barcode: barcode)
        )
        return ProductDetails(from: response, qrCode: barcode)
    }
}
