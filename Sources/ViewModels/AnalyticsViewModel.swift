import Foundation

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var analytics: DNSAnalytics?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = CloudflareAPIClient()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            analytics = try await api.fetchDNSAnalytics()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
