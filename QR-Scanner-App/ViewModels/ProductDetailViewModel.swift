import SwiftUI

struct ProductDetailViewModel: Identifiable {

    private let product: ProductDetails

    init(product: ProductDetails) {
        self.product = product
    }

    var id: String { product.barcode }

    var productName: String { product.productName }
    var brand: String { product.brand }
    var category: String { product.category }
    var barcode: String { product.barcode }
    var quantity: String? { product.quantity }
    var imageURL: String? { product.imageURL }
    var heroAccessibilityLabel: String { "Status: \(product.status.rawValue). Product: \(productName)" }

    var statusLabel: String { product.status.rawValue.uppercased() }
    var statusIcon: String { product.status == .genuine ? "checkmark.seal.fill" : "xmark.seal.fill" }
    var statusColor: Color { AppTheme.color(for: product.status) }
    var statusIconBackground: Color { statusColor.opacity(0.12) }
    var statusPillBackground: Color { statusColor.opacity(0.10) }
}
