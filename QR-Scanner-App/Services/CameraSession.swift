import AVFoundation

/// Owns the AVCaptureSession and runs all camera work on a shared serial queue.
/// Static queue ensures consecutive scanner sessions are serialized:
/// the old session's stopRunning() always completes before the new session configures.
final class CameraSession: NSObject, @unchecked Sendable {

    let captureSession = AVCaptureSession()
    var onCodeDetected: ((String) -> Void)?
    var onSetupFailed: (() -> Void)?

    // Shared across ALL CameraSession instances so stop → start is always ordered.
    private static let queue = DispatchQueue(label: "com.qrscanner.camera", qos: .userInitiated)
    private var isConfigured = false

    deinit {
        let session = captureSession
        CameraSession.queue.async {
            if session.isRunning { session.stopRunning() }
        }
    }

    // MARK: - Public API

    func start() {
        CameraSession.queue.async { [weak self] in self?.configure() }
    }

    func stop() {
        CameraSession.queue.async { [weak self] in
            guard let self, captureSession.isRunning else { return }
            captureSession.stopRunning()
        }
    }

    func resume() {
        CameraSession.queue.async { [weak self] in
            guard let self, !captureSession.isRunning else { return }
            captureSession.startRunning()
        }
    }

    // MARK: - Session configuration (always on CameraSession.queue)

    private func configure() {
        if isConfigured {
            if !captureSession.isRunning { captureSession.startRunning() }
            return
        }

        captureSession.beginConfiguration()

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input)
        else {
            captureSession.commitConfiguration()
            onSetupFailed?()
            return
        }
        captureSession.addInput(input)

        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else {
            captureSession.commitConfiguration()
            onSetupFailed?()
            return
        }
        captureSession.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: CameraSession.queue)
        metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .upce, .code128, .code39, .code93]

        captureSession.commitConfiguration()
        isConfigured = true
        captureSession.startRunning()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraSession: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let readable = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = readable.stringValue
        else { return }

        onCodeDetected?(code)
    }
}
