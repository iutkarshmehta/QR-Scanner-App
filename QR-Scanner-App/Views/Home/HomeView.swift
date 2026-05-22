import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Scan a product QR code to instantly verify its authenticity and detect counterfeits.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)

                    NavigationLink(destination: ScannerView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 18, weight: .medium))
                            Text("Scan a QR Code")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(Color(.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.primary, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .tint(Color(.systemBackground))
                    .shadow(color: Color.primary.opacity(0.20), radius: 14, y: 5)
                    .padding(.horizontal, 28)
                }
            }
            .navigationTitle("Verify QRs")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
