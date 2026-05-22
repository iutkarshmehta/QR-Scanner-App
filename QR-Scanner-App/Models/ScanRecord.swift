import Foundation
import SwiftData

enum VerificationStatus: String, Codable, CaseIterable {
    case genuine = "Genuine"
    case unverified = "Unverified"
}

@Model
final class ScanRecord {
    var id: UUID
    var qrCode: String
    var productName: String
    var brand: String
    var category: String
    var status: VerificationStatus
    var scannedAt: Date
    var imageURL: String?
    var quantity: String?

    init(
        id: UUID = UUID(),
        qrCode: String,
        productName: String,
        brand: String,
        category: String,
        status: VerificationStatus,
        scannedAt: Date = Date(),
        imageURL: String? = nil,
        quantity: String? = nil
    ) {
        self.id = id
        self.qrCode = qrCode
        self.productName = productName
        self.brand = brand
        self.category = category
        self.status = status
        self.scannedAt = scannedAt
        self.imageURL = imageURL
        self.quantity = quantity
    }
}
