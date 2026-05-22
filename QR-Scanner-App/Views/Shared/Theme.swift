import SwiftUI

enum AppTheme {
    // Accent used on interactive elements and scanner corners
    static let accent = Color(red: 0.40, green: 0.38, blue: 0.95)   // indigo-violet

    // Semantic status colours
    static let genuine = Color(red: 0.18, green: 0.78, blue: 0.44) // emerald
    static let spurious = Color(red: 0.96, green: 0.27, blue: 0.33) // rose-red

    static func color(for status: VerificationStatus) -> Color {
        status == .genuine ? genuine : spurious
    }

    static func softBackground(for status: VerificationStatus) -> Color {
        color(for: status).opacity(0.09)
    }

    // Card shadow
    static let cardShadow = Color.black.opacity(0.07)
}

// MARK: - Convenience modifiers

extension View {
    func appCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 3)
    }
}
