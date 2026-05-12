import Foundation

@MainActor
final class DNSRecordListViewModel: ObservableObject {
    @Published var records: [DNSRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var warningMessage: String?

    private let api = CloudflareAPIClient()

    func loadRecords(zoneID: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await api.fetchDNSRecords(zoneID: zoneID)
            records = result.items
            errorMessage = nil
            warningMessage = result.skippedCount > 0 ? "有 \(result.skippedCount) 条特殊记录未完整展示" : nil
        } catch {
            errorMessage = error.localizedDescription
            warningMessage = nil
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
