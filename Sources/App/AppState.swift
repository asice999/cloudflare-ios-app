import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var currentError: String?

    private let keychain = KeychainService()

    init() {
        Task {
            await restoreSession()
        }
    }

    func restoreSession() async {
        let token = keychain.readToken()
        isAuthenticated = !(token?.isEmpty ?? true)
        isCheckingAuth = false
    }

    func login(token: String) async throws {
        try keychain.saveToken(token)
        isAuthenticated = true
        currentError = nil
    }

    func logout() {
        keychain.deleteToken()
        isAuthenticated = false
    }
}
