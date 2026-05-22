import AVFoundation
import SwiftData
import Observation

enum ScannerState: Equatable {
    case idle
    case scanning
    case loading
    case result(ProductDetails)
    case error(String)
    case noConnectivity
    case permissionDenied

    static func == (lhs: ScannerState, rhs: ScannerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.scanning, .scanning), (.loading, .loading),
             (.noConnectivity, .noConnectivity), (.permissionDenied, .permissionDenied): return true
        case (.error(let a),  .error(let b)):  return a == b
        case (.result(let a), .result(let b)): return a.barcode == b.barcode
        default: return false
        }
    }
}

@Observable @MainActor
final class ScannerViewModel {

    var state: ScannerState = .idle

    var captureSession: AVCaptureSession { camera.captureSession }

    private let camera = CameraSession()
    private let repository: any ProductRepository
    private var isProcessing = false
    private var modelContext: ModelContext?

    init(repository: (any ProductRepository)? = nil) {
        // Default resolved inside @MainActor init body, not in the default parameter
        // expression, which would be evaluated in a nonisolated context.
        self.repository = repository ?? OpenFoodFactsRepository.shared
    }

    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    // MARK: - Lifecycle

    func checkPermissionsAndStart() {
        // Wire callbacks before starting — both arrive on camera.queue, hop here.
        camera.onCodeDetected = { [weak self] code in
            Task { @MainActor [weak self] in self?.handleDetected(code: code) }
        }
        camera.onSetupFailed = { [weak self] in
            Task { @MainActor [weak self] in self?.state = .error("Unable to access camera.") }
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            camera.start()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.camera.start()
                } else {
                    Task { @MainActor [weak self] in self?.state = .permissionDenied }
                }
            }
        default:
            state = .permissionDenied
        }
    }

    func stopSession() {
        camera.onCodeDetected = nil
        camera.onSetupFailed = nil
        camera.stop()
    }

    func resumeScanning() {
        isProcessing = false
        state = .scanning
        camera.resume()
    }

    // MARK: - Verification

    private func handleDetected(code: String) {
        guard !isProcessing else { return }

        // Fast offline check — avoids locking the scanner for a request we know will fail.
        // State is only set when transitioning in, to avoid spamming onChange.
        guard NetworkMonitor.shared.isConnected else {
            if state != .noConnectivity { state = .noConnectivity }
            return
        }

        isProcessing = true
        state = .loading
        camera.stop()

        Task { [weak self] in
            guard let self else { return }
            do {
                let details = try await repository.fetchProduct(barcode: code)
                saveToHistory(details)
                isProcessing = false
                state = .result(details)
            } catch let apiError as APIError {
                isProcessing = false
                switch apiError {
                case .noConnectivity:
                    // Don't pollute history — user can retry once back online.
                    state = .noConnectivity
                default:
                    saveUnverified(qrCode: code)
                    state = .error(apiError.localizedDescription)
                }
            } catch {
                isProcessing = false
                saveUnverified(qrCode: code)
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Persistence

    private func saveToHistory(_ details: ProductDetails) {
        guard let modelContext else { return }
        modelContext.insert(ScanRecord(
            qrCode: details.barcode,
            productName: details.productName,
            brand: details.brand,
            category: details.category,
            status: details.status,
            imageURL: details.imageURL,
            quantity: details.quantity
        ))
    }

    private func saveUnverified(qrCode: String) {
        guard let modelContext else { return }
        modelContext.insert(ScanRecord(
            qrCode: qrCode,
            productName: "Unknown Product",
            brand: "N/A",
            category : "N/A",
            status: .unverified
        ))
    }
}
