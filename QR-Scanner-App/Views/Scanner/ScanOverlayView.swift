import SwiftUI

struct ScanOverlayView: View {
    @State private var pulse = false

    var body: some View {
        GeometryReader { geo in
            // GeometryReader can report zero or negative sizes during layout passes
            // (tab switches, orientation changes, navigation transitions).
            // Guard here so no child ever receives a non-positive frame dimension.
            if geo.size.width > 0, geo.size.height > 0 {
                let side = min(geo.size.width, geo.size.height) * 0.62
                let cx = geo.size.width  / 2
                let cy = geo.size.height / 2

                ZStack {
                    dimmingCutout(side: side)
                    cornerMarkers(side: side, cx: cx, cy: cy)
                    topLabel(cx: cx, cy: cy, side: side)
                    bottomLabel(cx: cx, cy: cy, side: side)
                }
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    // MARK: - Subviews

    /// Canvas-based dimming layer with a rounded-rectangle cut-out.
    /// Canvas + compositingGroup is the crash-safe alternative to
    /// .mask { .blendMode(.destinationOut) } which requires compositingGroup
    /// to work correctly and crashes without it on certain iOS versions.
    private func dimmingCutout(side: CGFloat) -> some View {
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(0.60))
            )
            let cutRect = CGRect(
                x: (size.width  - side) / 2,
                y: (size.height - side) / 2,
                width: side,
                height: side
            )
            var hole = Path()
            hole.addRoundedRect(in: cutRect, cornerSize: CGSize(width: 16, height: 16))
            context.blendMode = .destinationOut
            context.fill(hole, with: .color(.white))
        }
        .compositingGroup()
    }

    /// Animated corner brackets centred over the cut-out window.
    private func cornerMarkers(side: CGFloat, cx: CGFloat, cy: CGFloat) -> some View {
        ScannerCornerShape()
            .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            .frame(width: side, height: side)
            .position(x: cx, y: cy)
            .scaleEffect(pulse ? 1.03 : 1.0)
    }

    private func topLabel(cx: CGFloat, cy: CGFloat, side: CGFloat) -> some View {
        Text("SCAN QR CODE")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .tracking(2)
            .foregroundStyle(.white.opacity(0.70))
            .position(x: cx, y: max(cy - side / 2 - 44, 24))
    }

    private func bottomLabel(cx: CGFloat, cy: CGFloat, side: CGFloat) -> some View {
        Text("Align the code inside the frame")
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.55))
            .position(x: cx, y: cy + side / 2 + 44)
    }
}

// MARK: - Corner shape (unchanged)

struct ScannerCornerShape: Shape {
    var armLength: CGFloat = 28
    var radius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let a = armLength, r = radius

        // Top-left
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + r + a))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r),
                 radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX + r + a, y: rect.minY))

        // Top-right
        p.move(to: CGPoint(x: rect.maxX - r - a, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
                 radius: r, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + r + a))

        // Bottom-right
        p.move(to: CGPoint(x: rect.maxX, y: rect.maxY - r - a))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                 radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX - r - a, y: rect.maxY))

        // Bottom-left
        p.move(to: CGPoint(x: rect.minX + r + a, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
                 radius: r, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - r - a))

        return p
    }
}
