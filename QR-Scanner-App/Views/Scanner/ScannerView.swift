import SwiftUI
import SwiftData

struct ScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ScannerViewModel()
    @State private var scannedProduct: ProductDetailViewModel?

    // Alert state
    @State private var errorMessage: String = ""
    @State private var showErrorAlert = false
    @State private var showPermissionAlert = false
    @State private var showNoConnectivityAlert = false

    private let networkMonitor = NetworkMonitor.shared

    var body: some View {
        ZStack {
            cameraLayer
            closeButton
            if !networkMonitor.isConnected { offlineBanner }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.checkPermissionsAndStart()
        }
        .onDisappear { viewModel.stopSession() }
        .sheet(item: $scannedProduct, onDismiss: {
            viewModel.stopSession()
            dismiss()
        }) {
            ProductDetailView(vm: $0)
        }
        .onChange(of: viewModel.state) { _, newState in
            switch newState {
            case .result(let product):
                scannedProduct = ProductDetailViewModel(product: product)
            case .error(let msg):
                errorMessage = msg
                showErrorAlert = true
            case .noConnectivity:
                showNoConnectivityAlert = true
            case .permissionDenied:
                showPermissionAlert = true
            default:
                break
            }
        }
        // No internet connection
        .alert("No Internet Connection", isPresented: $showNoConnectivityAlert) {
            Button("Try Again") { viewModel.resumeScanning() }
            Button("Cancel", role: .cancel) { dismiss() }
        } message: {
            Text("Please check your connection and try scanning again.")
        }
        // Verification / network error
        .alert("Verification Failed", isPresented: $showErrorAlert) {
            Button("Try Again") { viewModel.resumeScanning() }
            Button("Cancel", role: .cancel) { dismiss() }
        } message: {
            Text(errorMessage)
        }
        // Camera permission denied
        .alert("Camera Access Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Please enable camera access in Settings to scan QR codes.")
        }
    }

    // MARK: - Camera layer

    private var cameraLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraPreviewView(session: viewModel.captureSession).ignoresSafeArea()
            ScanOverlayView()
            if case .loading = viewModel.state { VerifyingOverlay() }
        }
    }

    // MARK: - Offline banner

    private var offlineBanner: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 13, weight: .semibold))
                Text("No internet connection")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.black.opacity(0.70), in: Capsule())
            .padding(.bottom, 48)
        }
    }

    // MARK: - Close button

    private var closeButton: some View {
        VStack {
            HStack {
                Button {
                    viewModel.stopSession()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.18), in: Circle())
                }
                .padding(.leading, 20)
                .padding(.top, 60)
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - Verifying overlay

struct VerifyingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .tint(AppTheme.accent)
                    .scaleEffect(1.3)
                Text("Verifying…")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 28)
            .appCard(cornerRadius: 20)
        }
    }
}
