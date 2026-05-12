import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isCheckingAuth {
                ProgressView("检查登录状态…")
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
