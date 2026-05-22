import SwiftUI

struct ScanRecordViewModel: Identifiable {

    let record: ScanRecord

    var id: UUID { record.id }

    var productName: String { record.productName }
    var brand: String { record.brand }
    var category: String { record.category }
    var qrCode: String { record.qrCode }
    var quantity: String? { record.quantity }
    var shortDate: String { record.scannedAt.formatted(date: .abbreviated, time: .shortened) }
    var longDate: String { record.scannedAt.formatted(date: .long,        time: .shortened) }
    var accessibilityText: String {
        "\(productName), \(record.status.rawValue), scanned \(record.scannedAt.formatted())"
    }

    var statusLabel: String { record.status.rawValue.uppercased() }
    var statusLabelShort: String { record.status.rawValue }
    var statusIcon: String { record.status == .genuine ? "checkmark.seal.fill" : "xmark.seal.fill" }
    var statusColor: Color { AppTheme.color(for: record.status) }
    var statusBackground: Color { statusColor.opacity(0.12) }
    var statusPillBackground: Color { statusColor.opacity(0.10) }
    var heroBackground: Color { statusColor.opacity(0.12) }
}
