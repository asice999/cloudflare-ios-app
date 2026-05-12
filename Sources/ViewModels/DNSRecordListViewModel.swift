import Foundation

@MainActor
final class DNSRecordListViewModel: ObservableObject {
    @Published var records: [DNSRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = CloudflareAPIClient()

    func loadRecords(zoneID: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            records = try await api.fetchDNSRecords(zoneID: zoneID)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteRecord(zoneID: String, recordID: String) async {
        do {
            try await api.deleteDNSRecord(zoneID: zoneID, recordID: recordID)
            await loadRecords(zoneID: zoneID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
