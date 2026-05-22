import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [ScanRecord]
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if allRecords.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("History")
            .searchable(text: $viewModel.searchText, prompt: "Search product or brand")
            .toolbar { filterMenu }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.08))
                    .frame(width: 88, height: 88)
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(AppTheme.accent.opacity(0.70))
            }
            Text("No Scans Yet")
                .font(.system(size: 18, weight: .semibold))
            Text("Scan a QR code and your history\nwill appear here.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var list: some View {
        let items = viewModel.filtered(allRecords)
        List {
            if items.isEmpty {
                ContentUnavailableView.search
            } else {
                ForEach(items) { item in
                    NavigationLink { HistoryDetailView(vm: item) } label: {
                        HistoryRowView(vm: item)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color(.systemBackground))
                }
                .onDelete { offsets in
                    offsets.forEach { viewModel.delete(items[$0], in: modelContext) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: items.count)
    }

    @ToolbarContentBuilder
    private var filterMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button { viewModel.selectedStatus = nil } label: {
                    Label("All Scans", systemImage: "tray.full")
                }
                Divider()
                ForEach(VerificationStatus.allCases, id: \.self) { status in
                    Button { viewModel.selectedStatus = status } label: {
                        Label(status.rawValue, systemImage: viewModel.filterIcon(for: status))
                    }
                }
            } label: {
                Image(systemName: viewModel.filterIconName)
                    .foregroundStyle(viewModel.filterTintColor)
            }
        }
    }
}
