import SwiftUI

/// Global singleton that surfaces errors from any layer (networking, auth, etc.)
/// to the root UI overlay. Uses `@Observable` so SwiftUI auto-tracks changes.
@MainActor
@Observable
final class GlobalErrorManager {
    static let shared = GlobalErrorManager()
    private init() {}

    /// Last API error (nil for plain text messages).
    var error: APIError? = nil
    /// Plain text message (used for auth / validation errors).
    private(set) var customMessage: String? = nil
    /// Live countdown for rate-limit (429) errors.
    private(set) var remainingSeconds: Int? = nil
    var showError: Bool = false

    /// Default time (seconds) before the banner disappears on its own.
    private let autoDismissSeconds: Double = 5

    @ObservationIgnored private var dismissTask: Task<Void, Never>?
    @ObservationIgnored private var generation = 0

    /// Message shown in the banner; updates every second during a rate-limit countdown.
    var displayMessage: String {
        if let seconds = remainingSeconds {
            return seconds > 0
                ? "Çok fazla istek yapıldı. Lütfen \(seconds) saniye sonra tekrar deneyin."
                : "Tekrar deneyebilirsiniz."
        }
        if let customMessage { return customMessage }
        return error?.errorDescription ?? "Bilinmeyen bir hata oluştu."
    }

    var hasError: Bool { showError && (error != nil || customMessage != nil) }

    // MARK: - Public API

    /// Call from any context to show an error banner.
    func handle(_ error: Error?) {
        guard let error else { return }
        // Cancelled requests are not user-facing errors.
        if (error as? URLError)?.code == .cancelled || error is CancellationError { return }

        let apiError: APIError = (error as? APIError) ?? .unknown(error)
        var message: String? = nil
        var retry: Int? = nil

        switch apiError {
        case .tooManyRequests(let seconds):
            retry = seconds ?? 5
        case .unknown(let underlying):
            // Keep specific messages (e.g. Firebase errors) instead of a generic one.
            message = underlying.localizedDescription
        default:
            break
        }
        present(apiError: apiError, message: message, retry: retry)
    }

    /// Show a plain text error (auth, validation...).
    func handle(message: String) {
        present(apiError: nil, message: message, retry: nil)
    }

    /// Clears the error and animates the banner out.
    func clear() {
        dismissTask?.cancel()
        generation += 1
        let current = generation
        withAnimation(.easeInOut(duration: 0.3)) {
            showError = false
        }
        // Hata metnini animasyon bittikten sonra sil (flash önleme)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.35))
            guard current == self.generation else { return }
            self.error = nil
            self.customMessage = nil
            self.remainingSeconds = nil
        }
    }

    // MARK: - Private

    private func present(apiError: APIError?, message: String?, retry: Int?) {
        dismissTask?.cancel()
        generation += 1
        let current = generation

        self.error = apiError
        self.customMessage = message
        self.remainingSeconds = retry

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            showError = true
        }

        dismissTask = Task { @MainActor [weak self] in
            if let retry, retry > 0 {
                // Dynamic countdown
                var left = retry
                while left > 0 {
                    try? await Task.sleep(for: .seconds(1))
                    if Task.isCancelled { return }
                    left -= 1
                    self?.remainingSeconds = left
                }
                try? await Task.sleep(for: .seconds(1.5))
            } else {
                try? await Task.sleep(for: .seconds(self?.autoDismissSeconds ?? 5))
            }
            if Task.isCancelled { return }
            guard let self, current == self.generation else { return }
            self.clear()
        }
    }
}
