import SwiftUI

/// Global singleton that surfaces errors from any layer (networking, auth, etc.)
/// to the root UI overlay. Uses `@Observable` so SwiftUI auto-tracks changes.
@Observable
final class GlobalErrorManager {
    static let shared = GlobalErrorManager()
    private init() {}

    var error: APIError? = nil
    var showError: Bool = false

    /// Call from any async context to show an error banner.
    @MainActor
    func handle(_ error: Error?) {
        guard let error else { return } // nil hata gösterme
        if let apiError = error as? APIError {
            self.error = apiError
        } else {
            self.error = .unknown(error)
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            self.showError = true
        }
    }

    /// Clears the error and animates the banner out.
    @MainActor
    func clear() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.showError = false
        }
        // Hata metnini animasyon bittikten sonra sil (flash önleme)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.35))
            self.error = nil
        }
    }
}

