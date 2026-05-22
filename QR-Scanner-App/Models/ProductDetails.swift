import Foundation

struct OpenFoodFactsResponse: Decodable {
    let status: Int
    let product: RawProduct?

    private enum CodingKeys: String, CodingKey { case status, product }

    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status = try c.decode(Int.self, forKey: .status)
        product = try c.decodeIfPresent(RawProduct.self, forKey: .product)
    }
}

struct RawProduct: Decodable {
    let productName: String?
    let brands: String?
    let categories: String?
    let imageURL: String?
    let quantity: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case categories
        case imageURL = "image_url"
        case quantity
    }

    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        productName = try c.decodeIfPresent(String.self, forKey: .productName)
        brands = try c.decodeIfPresent(String.self, forKey: .brands)
        categories = try c.decodeIfPresent(String.self, forKey: .categories)
        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
        quantity = try c.decodeIfPresent(String.self, forKey: .quantity)
    }
}

struct ProductDetails {
    let barcode: String
    let productName: String
    let brand: String
    let category: String
    let status: VerificationStatus
    let imageURL: String?
    let quantity: String?

    nonisolated init(from response: OpenFoodFactsResponse, qrCode: String) {
        let p = response.product
        barcode = qrCode
        productName = p?.productName?.nonEmpty ?? "Unknown Product"
        brand = p?.brands?.components(separatedBy: ",").first?
                        .trimmingCharacters(in: .whitespaces).nonEmpty ?? "Unknown Brand"
        category = p?.categories?.components(separatedBy: ",").first?
                        .trimmingCharacters(in: .whitespaces).nonEmpty ?? "Uncategorized"
        status = response.status == 1 ? .genuine : .unverified
        imageURL = p?.imageURL
        quantity = p?.quantity
    }
}

private extension String {
    nonisolated var nonEmpty: String? { isEmpty ? nil : self }
}
