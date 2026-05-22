import SwiftUI

struct HistoryRowView: View {
    let vm: ScanRecordViewModel

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(vm.statusBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: vm.statusIcon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(vm.statusColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(vm.productName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(vm.brand)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(vm.shortDate)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(vm.statusLabelShort)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(vm.statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(vm.statusPillBackground, in: Capsule())
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(vm.accessibilityText)
    }
}
