import SwiftUI

struct RootView: View {

    let container: DIContainer

    @StateObject private var authViewModel: AuthViewModel
    // @State currentUser ve @State cancellables SİLİNDİ

    private let errorManager = GlobalErrorManager.shared

    init(container: DIContainer) {
        self.container = container
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: container.authService))
        // _currentUser = State(initialValue: ...) SİLİNDİ
    }

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Auth flow
            Group {
                if authViewModel.currentUser != nil {          // eskiden: currentUser != nil
                    MainTabView(container: container, authViewModel: authViewModel)
                        .transition(.opacity)
                } else {
                    NavigationStack {
                        LoginView(viewModel: authViewModel)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: authViewModel.currentUser == nil)

            // MARK: - Global error banner
            // (burası AYNEN kalıyor)
        }
        // .onAppear { ... sink ... } SİLİNDİ, yerine:
        .onChange(of: authViewModel.currentUser == nil) { _, isSignedOut in
            // Signed out: drop per-user cached data so the next account starts clean.
            if isSignedOut {
                container.recommendationService.clearCache()
            }
        }
    }
}
