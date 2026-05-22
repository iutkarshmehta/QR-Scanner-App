import SwiftUI

struct HistoryDetailView: View {
    let vm: ScanRecordViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                detailCard
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(vm.productName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(vm.heroBackground)
                    .frame(width: 88, height: 88)
                Image(systemName: vm.statusIcon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(vm.statusColor)
            }
            Text(vm.statusLabel)
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundStyle(vm.statusColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(vm.statusPillBackground, in: Capsule())
            Text(vm.productName)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .appCard()
    }

    private var detailCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Brand",        value: vm.brand,    icon: "tag")
            Divider().padding(.leading, 52)
            DetailRow(label: "Category",     value: vm.category, icon: "square.grid.2x2")
            if let qty = vm.quantity {
                Divider().padding(.leading, 52)
                DetailRow(label: "Quantity", value: qty,         icon: "scalemass")
            }
            Divider().padding(.leading, 52)
            DetailRow(label: "QR / Barcode", value: vm.qrCode,   icon: "qrcode")
            Divider().padding(.leading, 52)
            DetailRow(label: "Scanned",      value: vm.longDate, icon: "clock")
        }
        .appCard()
    }
}
