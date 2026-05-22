import SwiftUI
import SwiftData

@Observable
final class HistoryViewModel {
    var searchText: String = ""
    var selectedStatus: VerificationStatus? = nil

    var filterIconName: String {
        selectedStatus == nil ? "slider.horizontal.3" : "slider.horizontal.3"
    }

    var filterTintColor: Color {
        selectedStatus.map { AppTheme.color(for: $0) } ?? .primary
    }

    func filterIcon(for status: VerificationStatus) -> String {
        status == .genuine ? "checkmark.seal.fill" : "xmark.seal.fill"
    }

    func filtered(_ records: [ScanRecord]) -> [ScanRecordViewModel] {
        records
            .filter { record in
                let matchesSearch = searchText.isEmpty
                    || record.productName.localizedCaseInsensitiveContains(searchText)
                    || record.brand.localizedCaseInsensitiveContains(searchText)
                let matchesStatus = selectedStatus == nil || record.status == selectedStatus
                return matchesSearch && matchesStatus
            }
            .sorted { $0.scannedAt > $1.scannedAt }
            .map { ScanRecordViewModel(record: $0) }
    }

    func delete(_ item: ScanRecordViewModel, in context: ModelContext) {
        context.delete(item.record)
    }
}
