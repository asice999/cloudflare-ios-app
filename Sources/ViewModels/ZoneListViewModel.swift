import Foundation

@MainActor
final class ZoneListViewModel: ObservableObject {
    @Published var zones: [Zone] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = CloudflareAPIClient()

    func loadZones() async {
        isLoading = true
        defer { isLoading = false }
        do {
            zones = try await api.fetchZones()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
