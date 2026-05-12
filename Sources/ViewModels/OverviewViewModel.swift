import Foundation

@MainActor
final class OverviewViewModel: ObservableObject {
    @Published var overview: DashboardOverview?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = CloudflareAPIClient()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            overview = try await api.fetchDashboardOverview()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
