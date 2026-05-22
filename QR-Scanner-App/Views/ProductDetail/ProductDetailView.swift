import SwiftUI

struct ProductDetailView: View {
    let vm: ProductDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                    detailCard
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(vm.statusIconBackground)
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

            if let urlString = vm.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFit()
                            .frame(maxHeight: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            Text(vm.productName)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .appCard()
        .accessibilityLabel(vm.heroAccessibilityLabel)
    }

    private var detailCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Brand",        value: vm.brand,    icon: "tag")
            rowDivider
            DetailRow(label: "Category",     value: vm.category, icon: "square.grid.2x2")
            if let qty = vm.quantity {
                rowDivider
                DetailRow(label: "Quantity", value: qty,         icon: "scalemass")
            }
            rowDivider
            DetailRow(label: "QR / Barcode", value: vm.barcode, icon: "qrcode")
        }
        .appCard()
    }

    private var rowDivider: some View {
        Divider().padding(.leading, 52)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28, height: 28)
                .background(AppTheme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

